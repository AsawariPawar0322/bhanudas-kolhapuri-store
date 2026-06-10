"""
Sanand Footwear - Backend API
AI-powered, database-persistent platform for traditional craftsmen
"""

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime, timedelta
import random

# SQLAlchemy ORM Database Imports
from sqlalchemy import create_engine, Column, String, Integer, Float, Boolean, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session

# ============ FASTAPI SETUP ============
app = FastAPI(
    title="Sanand Footwear API",
    description="AI-powered demand prediction and PostgreSQL transaction system for Sanand Footwear",
    version="2.0.0"
)

# CORS for Flutter client
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============ DB CONNECTION & ORM CONFIG ============
DATABASE_URL = "postgresql://postgres:postgres@localhost:5432/sanand_footwear"

try:
    # Attempt to connect to local PostgreSQL DB
    engine = create_engine(DATABASE_URL)
    conn = engine.connect()
    conn.close()
    print("[Database] Connected successfully to production PostgreSQL database!")
except Exception as e:
    # Failover to SQLite if local PostgreSQL server is not started or installed
    print(f"[Database] PostgreSQL connection failed: {e}")
    print("[Database] Activating failover: Initializing SQLite local database (sanand_footwear.db)")
    DATABASE_URL = "sqlite:///sanand_footwear.db"
    engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False} if "sqlite" in DATABASE_URL else {})

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# ============ PYDANTIC SCHEMAS ============
class Product(BaseModel):
    id: str
    name: str
    category: str
    material: str
    color: str
    price: float
    stock: int
    rating: float
    image_url: str
    description: str

    class Config:
        from_attributes = True

class CartItem(BaseModel):
    product_id: str
    quantity: int

class Order(BaseModel):
    id: Optional[str] = None
    customer_name: str
    product: str
    color: str
    size: int
    quantity: int
    amount: float
    status: str = "pending"
    completion_days: Optional[int] = None
    source: str = "online"
    created_at: Optional[datetime] = None
    synced: bool = True

    class Config:
        from_attributes = True

# ============ SQLALCHEMY ORM SCHEMAS ============
class ProductDB(Base):
    __tablename__ = "products"
    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    category = Column(String, nullable=False)
    material = Column(String, nullable=False)
    color = Column(String, nullable=False)
    price = Column(Float, nullable=False)
    stock = Column(Integer, nullable=False)
    rating = Column(Float, nullable=False)
    image_url = Column(String, nullable=False)
    description = Column(String, nullable=False)

class CartItemDB(Base):
    __tablename__ = "cart_items"
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, index=True, nullable=False)
    product_id = Column(String, nullable=False)
    quantity = Column(Integer, nullable=False)

class OrderDB(Base):
    __tablename__ = "orders"
    id = Column(String, primary_key=True, index=True)
    customer_name = Column(String, nullable=False)
    product = Column(String, nullable=False)
    color = Column(String, nullable=False)
    size = Column(Integer, nullable=False)
    quantity = Column(Integer, nullable=False)
    amount = Column(Float, nullable=False)
    status = Column(String, default="pending")
    completion_days = Column(Integer, nullable=True)
    source = Column(String, default="online")
    created_at = Column(DateTime, default=datetime.now)
    synced = Column(Boolean, default=True)

# ============ DATABASE STARTUP & SEEDING ============
def init_db():
    # Build tables inside database instance
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    try:
        # Seed catalog products if empty
        if db.query(ProductDB).count() == 0:
            catalog = [
                ProductDB(
                    id="p1", 
                    name="Classic Tan Kolhapuri", 
                    category="Traditional", 
                    material="Leather", 
                    color="Tan", 
                    price=1200.0, 
                    stock=25, 
                    rating=4.8,
                    image_url="assets/images/classic_tan.png",
                    description="Authentic hand-stitched premium organic leather chappals from Sanand Co-op."
                ),
                ProductDB(
                    id="p2", 
                    name="Royal Wedding Gold", 
                    category="Wedding", 
                    material="Handwoven", 
                    color="Gold", 
                    price=2500.0, 
                    stock=10, 
                    rating=4.9,
                    image_url="assets/images/vibrant_blue.png",
                    description="Beautiful gold brocade weaving chappals crafted for weddings & special occasions."
                ),
                ProductDB(
                    id="p3", 
                    name="Daily Walk Black", 
                    category="Daily Wear", 
                    material="Rubber", 
                    color="Black", 
                    price=850.0, 
                    stock=45, 
                    rating=4.5,
                    image_url="assets/images/modern_black.png",
                    description="Durable rubber-soled footwear with ergonomic arch supports for daily comfort."
                ),
                ProductDB(
                    id="p4", 
                    name="Urban Casual Brown", 
                    category="Casual", 
                    material="Synthetic", 
                    color="Brown", 
                    price=950.0, 
                    stock=30, 
                    rating=4.2,
                    image_url="assets/images/classic_tan.png",
                    description="Modern synthetic leather casual footwear designed for everyday smart-casual use."
                ),
            ]
            db.add_all(catalog)
            db.commit()
            print("[Database] Seeding complete: Sanand Footwear catalog successfully stored in tables!")
            
        # Seed initial order if empty
        if db.query(OrderDB).count() == 0:
            initial_order = OrderDB(
                id="1248",
                customer_name="Rajesh Patil",
                product="Classic Tan Kolhapuri",
                color="Tan",
                size=9,
                quantity=2,
                amount=2400.0,
                status="pending",
                source="online",
                created_at=datetime.now(),
                synced=True
            )
            db.add(initial_order)
            db.commit()
            print("[Database] Seeding complete: Standard baseline transaction order populated!")
    finally:
        db.close()

# Session generator dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.on_event("startup")
def startup_event():
    init_db()

# ============ AI PREDICTION ENGINE (Rule-based) ============
festivals = {
    "Makar Sankranti": {"date": "2026-01-14", "impact": 0.23},
    "Republic Day": {"date": "2026-01-26", "impact": 0.15},
    "Holi": {"date": "2026-03-14", "impact": 0.30},
    "Diwali": {"date": "2026-11-01", "impact": 0.47},
}

def calculate_demand_prediction(target_date: datetime) -> dict:
    base_demand = 50
    day_factors = {0: 0.8, 1: 0.85, 2: 0.95, 3: 1.0, 4: 1.15, 5: 1.25, 6: 0.9}
    day_factor = day_factors.get(target_date.weekday(), 1.0)
    festival_boost = 0
    upcoming_festival = None
    
    for name, data in festivals.items():
        fest_date = datetime.strptime(data["date"], "%Y-%m-%d")
        days_until = (fest_date - target_date).days
        if 0 <= days_until <= 7:
            festival_boost = data["impact"] * (1 - days_until / 10)
            upcoming_festival = {"name": name, "days_until": days_until, "impact": data["impact"]}
            break
            
    month = target_date.month
    seasonal_factor = 1.3 if month in [11, 12, 1, 2] else 1.0
    weather_factor = random.uniform(1.0, 1.15)
    weather_condition = "Clear" if weather_factor > 1.05 else "Cloudy"
    prediction = min(100, base_demand * day_factor * seasonal_factor * (1 + festival_boost) * weather_factor)
    
    return {
        "demand_percentage": round(prediction), 
        "confidence": random.randint(85, 95),
        "factors": {
            "day_of_week": {"name": target_date.strftime("%A"), "impact": round((day_factor - 1) * 100)},
            "festival": upcoming_festival,
            "season": {"name": "Wedding Season" if seasonal_factor > 1 else "Regular", "impact": round((seasonal_factor - 1) * 100)},
            "weather": {"condition": weather_condition, "impact": round((weather_factor - 1) * 100)}
        }
    }

def get_weekly_forecast() -> List[dict]:
    forecast = []
    today = datetime.now()
    for i in range(7):
        date = today + timedelta(days=i)
        prediction = calculate_demand_prediction(date)
        forecast.append({
            "date": date.strftime("%Y-%m-%d"), 
            "day": date.strftime("%a"), 
            "is_today": i == 0, 
            "demand": prediction["demand_percentage"], 
            "is_peak": prediction["demand_percentage"] >= 90
        })
    return forecast

def get_production_recommendations() -> List[dict]:
    return [
        {"color": "Brown", "hex": "#8B4513", "quantity": 45, "priority": "high"},
        {"color": "Black", "hex": "#000000", "quantity": 32, "priority": "high"},
        {"color": "Tan", "hex": "#D2691E", "quantity": 28, "priority": "medium"},
        {"color": "Maroon", "hex": "#8B0000", "quantity": 15, "priority": "low"},
    ]

# ============ API ENDPOINTS ============

@app.get("/")
async def root():
    return {"name": "Sanand Footwear Database Core", "version": "2.0.0"}

# PRODUCTS
@app.get("/api/products")
async def get_products(category: Optional[str] = None, material: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(ProductDB)
    if category:
        query = query.filter(ProductDB.category == category)
    if material:
        query = query.filter(ProductDB.material == material)
    return query.all()

@app.get("/api/products/{id}")
async def get_product(id: str, db: Session = Depends(get_db)):
    product = db.query(ProductDB).filter(ProductDB.id == id).first()
    if product: return product
    raise HTTPException(status_code=404, detail="Product not found")

# CART
@app.get("/api/cart/{user_id}")
async def get_cart(user_id: str, db: Session = Depends(get_db)):
    items = db.query(CartItemDB).filter(CartItemDB.user_id == user_id).all()
    return [{"product_id": item.product_id, "quantity": item.quantity} for item in items]

@app.post("/api/cart/{user_id}")
async def add_to_cart(user_id: str, item: CartItem, db: Session = Depends(get_db)):
    existing = db.query(CartItemDB).filter(
        CartItemDB.user_id == user_id, 
        CartItemDB.product_id == item.product_id
    ).first()
    if existing:
        existing.quantity += item.quantity
    else:
        db.add(CartItemDB(user_id=user_id, product_id=item.product_id, quantity=item.quantity))
    db.commit()
    items = db.query(CartItemDB).filter(CartItemDB.user_id == user_id).all()
    return [{"product_id": item.product_id, "quantity": item.quantity} for item in items]

# ORDERS
@app.get("/api/orders")
async def get_orders(status: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(OrderDB)
    if status:
        query = query.filter(OrderDB.status == status)
    return query.all()

@app.post("/api/orders")
async def create_order(order: Order, db: Session = Depends(get_db)):
    # Generate sequential unique order ID starting at 1250
    order_count = db.query(OrderDB).count()
    new_id = str(order_count + 1250)
    
    new_order = OrderDB(
        id=new_id,
        customer_name=order.customer_name,
        product=order.product,
        color=order.color,
        size=order.size,
        quantity=order.quantity,
        amount=order.amount,
        status="pending",
        source=order.source,
        created_at=datetime.now(),
        synced=True
    )
    db.add(new_order)
    db.commit()
    db.refresh(new_order)
    
    return {
        "message": "Order request sent to artisan", 
        "order": {
            "id": new_order.id,
            "customer_name": new_order.customer_name,
            "product": new_order.product,
            "color": new_order.color,
            "size": new_order.size,
            "quantity": new_order.quantity,
            "amount": new_order.amount,
            "status": new_order.status,
            "completion_days": new_order.completion_days,
            "source": new_order.source,
            "created_at": new_order.created_at,
            "synced": new_order.synced
        }
    }

@app.put("/api/orders/{order_id}")
async def update_order(order_id: str, status: str, completion_days: Optional[int] = None, db: Session = Depends(get_db)):
    order = db.query(OrderDB).filter(OrderDB.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    order.status = status
    if completion_days is not None:
        order.completion_days = completion_days
    db.commit()
    db.refresh(order)
    return {"message": f"Order {status}", "order": order}

@app.post("/api/login")
async def login(username: str, role: str):
    return {"user": {"username": username, "role": role, "id": f"u_{random.randint(100, 999)}"}}

# AI & IMPACT Stats (Rule-based)
@app.get("/api/predictions/today")
async def get_today_prediction(): 
    return calculate_demand_prediction(datetime.now())

@app.get("/api/predictions/weekly")
async def get_weekly_predictions():
    return {"forecast": get_weekly_forecast()}

@app.get("/api/predictions/recommendations")
async def get_recommendations_endpoint():
    return {"recommendations": get_production_recommendations()}

@app.get("/api/impact")
async def get_impact_stats(): 
    return {
        "waste_prevented_kg": 182,
        "waste_reduction_percent": 38, 
        "production_accuracy": 91, 
        "carbon_saved_kg": 490,
        "income_growth_percent": 26,
        "artisans_connected": 16
    }

# Festival data
@app.get("/api/festivals/upcoming")
async def get_upcoming_festivals():
    today = datetime.now()
    upcoming = []
    
    for name, data in festivals.items():
        fest_date = datetime.strptime(data["date"], "%Y-%m-%d")
        days_until = (fest_date - today).days
        if days_until >= 0:
            upcoming.append({
                "name": name,
                "date": data["date"],
                "days_until": days_until,
                "demand_impact_percent": int(data["impact"] * 100)
            })
    
    return sorted(upcoming, key=lambda x: x["days_until"])

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
