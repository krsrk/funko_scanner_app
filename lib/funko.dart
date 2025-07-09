class Funko {
  final int funkoId;
  final String funkoType;
  final String funkoName;
  final String funkoLicense;
  final String funkoSeries;
  final String funkoSticker;
  int quantity;
  final String imagesPath;

  Funko({
    required this.funkoId,
    required this.funkoType,
    required this.funkoName,
    required this.funkoLicense,
    required this.funkoSeries,
    required this.funkoSticker,
    required this.quantity,
    required this.imagesPath,
  });

  Map<String, dynamic> toJson() => {
        'funko_id': funkoId,
        'funko_type': funkoType,
        'funko_name': funkoName,
        'funko_license': funkoLicense,
        'funko_series': funkoSeries,
        'funko_sticker': funkoSticker,
        'quantity': quantity,
        'images_path': imagesPath,
      };

  factory Funko.fromJson(Map<String, dynamic> json) => Funko(
        funkoId: json['funko_id'],
        funkoType: json['funko_type'],
        funkoName: json['funko_name'],
        funkoLicense: json['funko_license'],
        funkoSeries: json['funko_series'],
        funkoSticker: json['funko_sticker'],
        quantity: json['quantity'],
        imagesPath: json['images_path'],
      );
} 