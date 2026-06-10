class Prediction {
  final int demandPercentage;
  final int confidence;
  final PredictionFactors factors;

  Prediction({
    required this.demandPercentage,
    required this.confidence,
    required this.factors,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      demandPercentage: json['demand_percentage'],
      confidence: json['confidence'],
      factors: PredictionFactors.fromJson(json['factors']),
    );
  }

  String get demandLevel {
    if (demandPercentage >= 80) return 'Very High';
    if (demandPercentage >= 60) return 'High';
    if (demandPercentage >= 40) return 'Medium';
    return 'Low';
  }

  String get demandEmoji {
    if (demandPercentage >= 80) return '🔥';
    if (demandPercentage >= 60) return '📈';
    if (demandPercentage >= 40) return '📊';
    return '📉';
  }
}

class PredictionFactors {
  final DayFactor dayOfWeek;
  final FestivalFactor? festival;
  final SeasonFactor season;
  final WeatherFactor weather;

  PredictionFactors({
    required this.dayOfWeek,
    this.festival,
    required this.season,
    required this.weather,
  });

  factory PredictionFactors.fromJson(Map<String, dynamic> json) {
    return PredictionFactors(
      dayOfWeek: DayFactor.fromJson(json['day_of_week']),
      festival: json['festival'] != null 
          ? FestivalFactor.fromJson(json['festival']) 
          : null,
      season: SeasonFactor.fromJson(json['season']),
      weather: WeatherFactor.fromJson(json['weather']),
    );
  }
}

class DayFactor {
  final String name;
  final int impact;

  DayFactor({required this.name, required this.impact});

  factory DayFactor.fromJson(Map<String, dynamic> json) {
    return DayFactor(
      name: json['name'],
      impact: json['impact'],
    );
  }
}

class FestivalFactor {
  final String name;
  final int daysUntil;
  final double impact;

  FestivalFactor({
    required this.name,
    required this.daysUntil,
    required this.impact,
  });

  factory FestivalFactor.fromJson(Map<String, dynamic> json) {
    return FestivalFactor(
      name: json['name'],
      daysUntil: json['days_until'],
      impact: (json['impact'] as num).toDouble(),
    );
  }
}

class SeasonFactor {
  final String name;
  final int impact;

  SeasonFactor({required this.name, required this.impact});

  factory SeasonFactor.fromJson(Map<String, dynamic> json) {
    return SeasonFactor(
      name: json['name'],
      impact: json['impact'],
    );
  }
}

class WeatherFactor {
  final String condition;
  final int impact;

  WeatherFactor({required this.condition, required this.impact});

  factory WeatherFactor.fromJson(Map<String, dynamic> json) {
    return WeatherFactor(
      condition: json['condition'],
      impact: json['impact'],
    );
  }

  String get emoji {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'cloudy':
        return '⛅';
      case 'rainy':
        return '🌧️';
      default:
        return '🌤️';
    }
  }
}
