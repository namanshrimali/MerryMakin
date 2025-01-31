enum CountryCurrency {
  AfghanAfghani,
  AlbanianLek,
  AlgerianDinar,
  AngolanKwanza,
  ArgentinePeso,
  ArmenianDram,
  AustralianDollar,
  AustrianEuro,
  AzerbaijaniManat,
  BahrainiDinar,
  BangladeshiTaka,
  BarbadianDollar,
  BelarusianRuble,
  BelizeDollar,
  BeninWestAfricanCFADollar,
  BhutaneseNgultrum,
  BolivianBoliviano,
  BosniaHerzegovinaConvertibleMark,
  BotswanaPula,
  BrazilianReal,
  BruneiDollar,
  BulgarianLev,
  BurundianFranc,
  CambodianRiel,
  CameroonianCentralAfricanCFADollar,
  CanadianDollar,
  CapeVerdeanEscudo,
  CentralAfricanCFADollar,
  ChileanPeso,
  ChineseYuan,
  ColombianPeso,
  ComorianFranc,
  CongoleseFranc,
  CostaRicanColon,
  CroatianKuna,
  CubanPeso,
  CzechKoruna,
  DanishKrone,
  DjiboutianFranc,
  DominicanPeso,
  EastCaribbeanDollar,
  EgyptianPound,
  SalvadoranColon,
  EritreanNakfa,
  EstonianEuro,
  SwaziLilangeni,
  EthiopianBirr,
  FijianDollar,
  FinnishEuro,
  FrenchEuro,
  GaboneseCentralAfricanCFADollar,
  GambianDalasi,
  GeorgianLari,
  GhanaianCedi,
  GreekEuro,
  GuatemalanQuetzal,
  GuineanFranc,
  GuyaneseDollar,
  HaitianGourde,
  HonduranLempira,
  HongKongDollar,
  HungarianForint,
  IcelandicKrona,
  IndianRupee,
  IndonesianRupiah,
  IranianRial,
  IraqiDinar,
  IsraeliNewShekel,
  ItalianEuro,
  JamaicanDollar,
  JapaneseYen,
  JordanianDinar,
  KazakhstaniTenge,
  KenyanShilling,
  KuwaitiDinar,
  KyrgyzstaniSom,
  LaoKip,
  LatvianEuro,
  LebanesePound,
  LesothoLoti,
  LiberianDollar,
  LibyanDinar,
  SwissFranc,
  LithuanianEuro,
  LuxembourgishEuro,
  MacanesePataca,
  MalagasyAriary,
  MalawianKwacha,
  MalaysianRinggit,
  MaldivianRufiyaa,
  MalianWestAfricanCFADollar,
  MauritanianOuguiya,
  MauritianRupee,
  MexicanPeso,
  MoldovanLeu,
  MongolianTogrog,
  MoroccanDirham,
  MozambicanMetical,
  BurmeseKyat,
  NamibianDollar,
  NepaleseRupee,
  DutchEuro,
  NewZealandDollar,
  NicaraguanCordoba,
  NigerianNaira,
  NorthKoreanWon,
  MacedonianDenar,
  NorwegianKrone,
  OmaniRial,
  PakistaniRupee,
  PanamanianBalboa,
  PapuaNewGuineanKina,
  ParaguayanGuarani,
  PeruvianSol,
  PhilippinePeso,
  PolishZloty,
  QatariRiyal,
  RomanianLeu,
  RussianRuble,
  RwandanFranc,
  EastCaribbeanDollarSaintKittsAndNevis,
  EastCaribbeanDollarSaintLucia,
  EastCaribbeanDollarSaintVincentAndTheGrenadines,
  SamoanTala,
  SaoTomeAndPrincipeDobra,
  SaudiRiyal,
  WestAfricanCFADollarSenegal,
  SerbianDinar,
  SeychelloisRupee,
  SierraLeoneanLeone,
  SingaporeDollar,
  SlovakKoruna,
  SlovenianTolar,
  SolomonIslandsDollar,
  SomaliShilling,
  SouthAfricanRand,
  SouthKoreanWon,
  SouthSudanesePound,
  SpanishEuro,
  SriLankanRupee,
  SudanesePound,
  SurinameseDollar,
  SwedishKrona,
  SwissFrancLiechtenstein,
  SwissFrancSwitzerland,
  SyrianPound,
  NewTaiwanDollar,
  TajikistaniSomoni,
  TanzanianShilling,
  ThaiBaht,
  WestAfricanCFADollarTogo,
  TonganPaanga,
  TrinidadAndTobagoDollar,
  TunisianDinar,
  TurkishLira,
  TurkmenistaniManat,
  TuvaluanAustralianDollar,
  UgandanShilling,
  UkrainianHryvnia,
  UnitedArabEmiratesDirhamUnitedArabEmirates,
  BritishPoundSterlingUnitedKingdom,
  UnitedStatesDollarUnitedStates,
  UruguayanPeso,
  UzbekistaniSom,
  VanuatuVatu,
  VenezuelanBolvar,
  VietnameseDong,
  YemeniRial,
  ZambianKwacha,
  ZimbabweanDollar,
}


  CountryCurrency fromJson(Map<String, dynamic> json) {
    return CountryCurrency.values.byName(json['name']);
  }

extension CountryCurrencyExtensions on CountryCurrency {

  toJson() {
    return {'name': name};
  }

  String getCurrencyCode() {
  switch (this) {
    case CountryCurrency.AfghanAfghani:
      return "AFN";
    case CountryCurrency.AlbanianLek:
      return "ALL";
    case CountryCurrency.AlgerianDinar:
      return "DZD";
    case CountryCurrency.AngolanKwanza:
      return "AOA";
    case CountryCurrency.ArgentinePeso:
      return "ARS";
    case CountryCurrency.ArmenianDram:
      return "AMD";
    case CountryCurrency.AustralianDollar:
      return "AUD";
    case CountryCurrency.AustrianEuro:
      return "EUR";
    case CountryCurrency.AzerbaijaniManat:
      return "AZN";
    case CountryCurrency.BahrainiDinar:
      return "BHD";
    case CountryCurrency.BangladeshiTaka:
      return "BDT";
    case CountryCurrency.BarbadianDollar:
      return "BBD";
    case CountryCurrency.BelarusianRuble:
      return "BYN";
    case CountryCurrency.BelizeDollar:
      return "BZD";
    case CountryCurrency.BeninWestAfricanCFADollar:
      return "XOF";
    case CountryCurrency.BhutaneseNgultrum:
      return "BTN";
    case CountryCurrency.BolivianBoliviano:
      return "BOB";
    case CountryCurrency.BosniaHerzegovinaConvertibleMark:
      return "BAM";
    case CountryCurrency.BotswanaPula:
      return "BWP";
    case CountryCurrency.BrazilianReal:
      return "BRL";
    case CountryCurrency.BruneiDollar:
      return "BND";
    case CountryCurrency.BulgarianLev:
      return "BGN";
    case CountryCurrency.BurundianFranc:
      return "BIF";
    case CountryCurrency.CambodianRiel:
      return "KHR";
    case CountryCurrency.CameroonianCentralAfricanCFADollar:
      return "XAF";
    case CountryCurrency.CanadianDollar:
      return "CAD";
    case CountryCurrency.CapeVerdeanEscudo:
      return "CVE";
    case CountryCurrency.CentralAfricanCFADollar:
      return "XAF";
    case CountryCurrency.ChileanPeso:
      return "CLP";
    case CountryCurrency.ChineseYuan:
      return "CNY";
    case CountryCurrency.ColombianPeso:
      return "COP";
    case CountryCurrency.ComorianFranc:
      return "KMF";
    case CountryCurrency.CongoleseFranc:
      return "CDF";
    case CountryCurrency.CostaRicanColon:
      return "CRC";
    case CountryCurrency.CroatianKuna:
      return "HRK";
    case CountryCurrency.CubanPeso:
      return "CUP";
    case CountryCurrency.CzechKoruna:
      return "CZK";
    case CountryCurrency.DanishKrone:
      return "DKK";
    case CountryCurrency.DjiboutianFranc:
      return "DJF";
    case CountryCurrency.DominicanPeso:
      return "DOP";
    case CountryCurrency.EastCaribbeanDollar:
      return "XCD";
    case CountryCurrency.EgyptianPound:
      return "EGP";
    case CountryCurrency.SalvadoranColon:
      return "SVC";
    case CountryCurrency.EritreanNakfa:
      return "ERN";
    case CountryCurrency.EstonianEuro:
      return "EUR";
    case CountryCurrency.SwaziLilangeni:
      return "SZL";
    case CountryCurrency.EthiopianBirr:
      return "ETB";
    case CountryCurrency.FijianDollar:
      return "FJD";
    case CountryCurrency.FinnishEuro:
      return "EUR";
    case CountryCurrency.FrenchEuro:
      return "EUR";
    case CountryCurrency.GaboneseCentralAfricanCFADollar:
      return "XAF";
    case CountryCurrency.GambianDalasi:
      return "GMD";
    case CountryCurrency.GeorgianLari:
      return "GEL";
    case CountryCurrency.GhanaianCedi:
      return "GHS";
    case CountryCurrency.GreekEuro:
      return "EUR";
    case CountryCurrency.GuatemalanQuetzal:
      return "GTQ";
    case CountryCurrency.GuineanFranc:
      return "GNF";
    case CountryCurrency.GuyaneseDollar:
      return "GYD";
    case CountryCurrency.HaitianGourde:
      return "HTG";
    case CountryCurrency.HonduranLempira:
      return "HNL";
    case CountryCurrency.HongKongDollar:
      return "HKD";
    case CountryCurrency.HungarianForint:
      return "HUF";
    case CountryCurrency.IcelandicKrona:
      return "ISK";
    case CountryCurrency.IndianRupee:
      return "INR";
    case CountryCurrency.IndonesianRupiah:
      return "IDR";
    case CountryCurrency.IranianRial:
      return "IRR";
    case CountryCurrency.IraqiDinar:
      return "IQD";
    case CountryCurrency.IsraeliNewShekel:
      return "ILS";
    case CountryCurrency.ItalianEuro:
      return "EUR";
    case CountryCurrency.JamaicanDollar:
      return "JMD";
    case CountryCurrency.JapaneseYen:
      return "JPY";
    case CountryCurrency.JordanianDinar:
      return "JOD";
    case CountryCurrency.KazakhstaniTenge:
      return "KZT";
    case CountryCurrency.KenyanShilling:
      return "KES";
    case CountryCurrency.KuwaitiDinar:
      return "KWD";
    case CountryCurrency.KyrgyzstaniSom:
      return "KGS";
    case CountryCurrency.LaoKip:
      return "LAK";
    case CountryCurrency.LatvianEuro:
      return "EUR";
    case CountryCurrency.LebanesePound:
      return "LBP";
    case CountryCurrency.LesothoLoti:
      return "LSL";
    case CountryCurrency.LiberianDollar:
      return "LRD";
    case CountryCurrency.LibyanDinar:
      return "LYD";
    case CountryCurrency.SwissFranc:
      return "CHF";
    case CountryCurrency.LithuanianEuro:
      return "EUR";
    case CountryCurrency.LuxembourgishEuro:
      return "EUR";
    case CountryCurrency.MacanesePataca:
      return "MOP";
    case CountryCurrency.MalagasyAriary:
      return "MGA";
    case CountryCurrency.MalawianKwacha:
      return "MWK";
    case CountryCurrency.MalaysianRinggit:
      return "MYR";
    case CountryCurrency.MaldivianRufiyaa:
      return "MVR";
    case CountryCurrency.MalianWestAfricanCFADollar:
      return "XOF";
    case CountryCurrency.BhutaneseNgultrum:
      return "BTN";
    case CountryCurrency.BolivianBoliviano:
      return "BOB";
    case CountryCurrency.BosniaHerzegovinaConvertibleMark:
      return "BAM";
    case CountryCurrency.BotswanaPula:
      return "BWP";
    case CountryCurrency.BrazilianReal:
      return "BRL";
    case CountryCurrency.BruneiDollar:
      return "BND";
    case CountryCurrency.BulgarianLev:
      return "BGN";
    case CountryCurrency.BurundianFranc:
      return "BIF";
    case CountryCurrency.CambodianRiel:
      return "KHR";
    case CountryCurrency.CameroonianCentralAfricanCFADollar:
      return "XAF";
    case CountryCurrency.CanadianDollar:
      return "CAD";
    case CountryCurrency.CapeVerdeanEscudo:
      return "CVE";
    case CountryCurrency.CentralAfricanCFADollar:
      return "XAF";
    case CountryCurrency.ChileanPeso:
      return "CLP";
    case CountryCurrency.ChineseYuan:
      return "CNY";
    case CountryCurrency.ColombianPeso:
      return "COP";
    case CountryCurrency.ComorianFranc:
      return "KMF";
    case CountryCurrency.CongoleseFranc:
      return "CDF";
    case CountryCurrency.CostaRicanColon:
      return "CRC";
    case CountryCurrency.CroatianKuna:
      return "HRK";
    case CountryCurrency.CubanPeso:
      return "CUP";
    case CountryCurrency.CzechKoruna:
      return "CZK";
    case CountryCurrency.DanishKrone:
      return "DKK";
    case CountryCurrency.DjiboutianFranc:
      return "DJF";
    case CountryCurrency.DominicanPeso:
      return "DOP";
    case CountryCurrency.EastCaribbeanDollar:
      return "XCD";
    case CountryCurrency.EgyptianPound:
      return "EGP";
    case CountryCurrency.SalvadoranColon:
      return "SVC";
    case CountryCurrency.EritreanNakfa:
      return "ERN";
    case CountryCurrency.EstonianEuro:
      return "EUR";
    case CountryCurrency.SwaziLilangeni:
      return "SZL";
    case CountryCurrency.EthiopianBirr:
      return "ETB";
    case CountryCurrency.FijianDollar:
      return "FJD";
    case CountryCurrency.FinnishEuro:
      return "EUR";
    case CountryCurrency.FrenchEuro:
      return "EUR";
    case CountryCurrency.GaboneseCentralAfricanCFADollar:
      return "XAF";
    case CountryCurrency.GambianDalasi:
      return "GMD";
    case CountryCurrency.GeorgianLari:
      return "GEL";
    case CountryCurrency.GhanaianCedi:
      return "GHS";
    case CountryCurrency.GreekEuro:
      return "EUR";
    case CountryCurrency.GuatemalanQuetzal:
      return "GTQ";
    case CountryCurrency.GuineanFranc:
      return "GNF";
    case CountryCurrency.GuyaneseDollar:
      return "GYD";
    case CountryCurrency.HaitianGourde:
      return "HTG";
    case CountryCurrency.HonduranLempira:
      return "HNL";
    case CountryCurrency.HongKongDollar:
      return "HKD";
    case CountryCurrency.HungarianForint:
      return "HUF";
    case CountryCurrency.IcelandicKrona:
      return "ISK";
    case CountryCurrency.IndianRupee:
      return "INR";
    case CountryCurrency.IndonesianRupiah:
      return "IDR";
    case CountryCurrency.IranianRial:
      return "IRR";
    case CountryCurrency.IraqiDinar:
      return "IQD";
    case CountryCurrency.IsraeliNewShekel:
      return "ILS";
    case CountryCurrency.ItalianEuro:
      return "EUR";
    case CountryCurrency.JamaicanDollar:
      return "JMD";
    case CountryCurrency.JapaneseYen:
      return "JPY";
    case CountryCurrency.JordanianDinar:
      return "JOD";
    case CountryCurrency.KazakhstaniTenge:
      return "KZT";
    case CountryCurrency.KenyanShilling:
      return "KES";
    case CountryCurrency.KuwaitiDinar:
      return "KWD";
    case CountryCurrency.KyrgyzstaniSom:
      return "KGS";
    case CountryCurrency.LaoKip:
      return "LAK";
    case CountryCurrency.LatvianEuro:
      return "EUR";
    case CountryCurrency.LebanesePound:
      return "LBP";
    case CountryCurrency.LesothoLoti:
      return "LSL";
    case CountryCurrency.LiberianDollar:
      return "LRD";
    case CountryCurrency.LibyanDinar:
      return "LYD";
    case CountryCurrency.SwissFranc:
      return "CHF";
    case CountryCurrency.LithuanianEuro:
      return "EUR";
    case CountryCurrency.LuxembourgishEuro:
      return "EUR";
    case CountryCurrency.MacanesePataca:
      return "MOP";
    case CountryCurrency.MalagasyAriary:
      return "MGA";
    case CountryCurrency.MalawianKwacha:
      return "MWK";
    case CountryCurrency.MalaysianRinggit:
      return "MYR";
    case CountryCurrency.MaldivianRufiyaa:
      return "MVR";
    case CountryCurrency.MalianWestAfricanCFADollar:
      return "XOF";
    case CountryCurrency.MauritanianOuguiya:
      return "MRU";
    case CountryCurrency.MauritianRupee:
      return "MUR";
    case CountryCurrency.MexicanPeso:
      return "MXN";
    case CountryCurrency.MoldovanLeu:
      return "MDL";
    case CountryCurrency.MongolianTogrog:
      return "MNT";
    case CountryCurrency.MoroccanDirham:
      return "MAD";
    case CountryCurrency.MozambicanMetical:
      return "MZN";
    case CountryCurrency.BurmeseKyat:
      return "MMK";
    case CountryCurrency.NamibianDollar:
      return "NAD";
    case CountryCurrency.NepaleseRupee:
      return "NPR";
    case CountryCurrency.DutchEuro:
      return "EUR";
    case CountryCurrency.NewZealandDollar:
      return "NZD";
    case CountryCurrency.NicaraguanCordoba:
      return "NIO";
    case CountryCurrency.NigerianNaira:
      return "NGN";
    case CountryCurrency.NorthKoreanWon:
      return "KPW";
    case CountryCurrency.MacedonianDenar:
      return "MKD";
    case CountryCurrency.NorwegianKrone:
      return "NOK";
    case CountryCurrency.OmaniRial:
      return "OMR";
    case CountryCurrency.PakistaniRupee:
      return "PKR";
    case CountryCurrency.PanamanianBalboa:
      return "PAB";
    case CountryCurrency.PapuaNewGuineanKina:
      return "PGK";
    case CountryCurrency.ParaguayanGuarani:
      return "PYG";
    case CountryCurrency.PeruvianSol:
      return "PEN";
    case CountryCurrency.PhilippinePeso:
      return "PHP";
    case CountryCurrency.PolishZloty:
      return "PLN";
    case CountryCurrency.QatariRiyal:
      return "QAR";
    case CountryCurrency.RomanianLeu:
      return "RON";
    case CountryCurrency.RussianRuble:
      return "RUB";
    case CountryCurrency.RwandanFranc:
      return "RWF";
    case CountryCurrency.EastCaribbeanDollarSaintKittsAndNevis:
      return "XCD";
    case CountryCurrency.EastCaribbeanDollarSaintLucia:
      return "XCD";
    case CountryCurrency.EastCaribbeanDollarSaintVincentAndTheGrenadines:
      return "XCD";
    case CountryCurrency.SamoanTala:
      return "WST";
    case CountryCurrency.SaoTomeAndPrincipeDobra:
      return "STN";
    case CountryCurrency.SaudiRiyal:
      return "SAR";
    case CountryCurrency.WestAfricanCFADollarSenegal:
      return "XOF";
    case CountryCurrency.SerbianDinar:
      return "RSD";
    case CountryCurrency.SeychelloisRupee:
      return "SCR";
    case CountryCurrency.SierraLeoneanLeone:
      return "SLL";
    case CountryCurrency.SingaporeDollar:
      return "SGD";
    case CountryCurrency.SlovakKoruna:
      return "SKK";
    case CountryCurrency.SlovenianTolar:
      return "SIT";
    case CountryCurrency.SolomonIslandsDollar:
      return "SBD";
    case CountryCurrency.SomaliShilling:
      return "SOS";
    case CountryCurrency.SouthAfricanRand:
      return "ZAR";
    case CountryCurrency.SouthKoreanWon:
      return "KRW";
    case CountryCurrency.SouthSudanesePound:
      return "SSP";
    case CountryCurrency.SpanishEuro:
      return "EUR";
    case CountryCurrency.SriLankanRupee:
      return "LKR";
    case CountryCurrency.SudanesePound:
      return "SDG";
    case CountryCurrency.SurinameseDollar:
      return "SRD";
    case CountryCurrency.SwedishKrona:
      return "SEK";
    case CountryCurrency.SwissFrancLiechtenstein:
      return "CHF";
    case CountryCurrency.SwissFrancSwitzerland:
      return "CHF";
    case CountryCurrency.SyrianPound:
      return "SYP";
    case CountryCurrency.NewTaiwanDollar:
      return "TWD";
    case CountryCurrency.TajikistaniSomoni:
      return "TJS";
    case CountryCurrency.TanzanianShilling:
      return "TZS";
    case CountryCurrency.ThaiBaht:
      return "THB";
    case CountryCurrency.WestAfricanCFADollarTogo:
      return "XOF";
    case CountryCurrency.TonganPaanga:
      return "TOP";
    case CountryCurrency.TrinidadAndTobagoDollar:
      return "TTD";
    case CountryCurrency.TunisianDinar:
      return "TND";
    case CountryCurrency.TurkishLira:
      return "TRY";
    case CountryCurrency.TurkmenistaniManat:
      return "TMT";
    case CountryCurrency.TuvaluanAustralianDollar:
      return "AUD";
    case CountryCurrency.UgandanShilling:
      return "UGX";
    case CountryCurrency.UkrainianHryvnia:
      return "UAH";
    case CountryCurrency.UnitedArabEmiratesDirhamUnitedArabEmirates:
      return "AED";
    case CountryCurrency.BritishPoundSterlingUnitedKingdom:
      return "GBP";
    case CountryCurrency.UnitedStatesDollarUnitedStates:
      return "USD";
    case CountryCurrency.UruguayanPeso:
      return "UYU";
    case CountryCurrency.UzbekistaniSom:
      return "UZS";
    case CountryCurrency.VanuatuVatu:
      return "VUV";
    case CountryCurrency.VenezuelanBolvar:
      return "VES";
    case CountryCurrency.VietnameseDong:
      return "VND";
    case CountryCurrency.YemeniRial:
      return "YER";
    case CountryCurrency.ZambianKwacha:
      return "ZMW";
    case CountryCurrency.ZimbabweanDollar:
      return "ZWL";
    default:
      return "XXX"; // Return "XXX" for unknown currency
  }
}


  String getCurrencySymbol() {
    switch (this) {
      case CountryCurrency.AfghanAfghani:
        return '؋';
      case CountryCurrency.AlbanianLek:
        return 'Lek';
      case CountryCurrency.AlgerianDinar:
        return 'د.ج';
      case CountryCurrency.AngolanKwanza:
        return 'Kz';
      case CountryCurrency.ArgentinePeso:
        return '\$';
      case CountryCurrency.ArmenianDram:
        return '֏';
      case CountryCurrency.AustralianDollar:
        return '\$';
      case CountryCurrency.AustrianEuro:
        return '€';
      case CountryCurrency.AzerbaijaniManat:
        return '₼';
      case CountryCurrency.BahrainiDinar:
        return '.د.ب';
      case CountryCurrency.BangladeshiTaka:
        return '৳';
      case CountryCurrency.BarbadianDollar:
        return '\$';
      case CountryCurrency.BelarusianRuble:
        return 'Br';
      case CountryCurrency.BelizeDollar:
        return 'BZ\$';
      case CountryCurrency.BeninWestAfricanCFADollar:
        return 'Fr';
      case CountryCurrency.BhutaneseNgultrum:
        return 'Nu.';
      case CountryCurrency.BolivianBoliviano:
        return 'Bs.';
      case CountryCurrency.BosniaHerzegovinaConvertibleMark:
        return 'KM';
      case CountryCurrency.BotswanaPula:
        return 'P';
      case CountryCurrency.BrazilianReal:
        return 'R\$';
      case CountryCurrency.BruneiDollar:
        return 'B\$';
      case CountryCurrency.BulgarianLev:
        return 'лв.';
      case CountryCurrency.BurundianFranc:
        return 'FBu';
      case CountryCurrency.CambodianRiel:
        return '៛';
      case CountryCurrency.CameroonianCentralAfricanCFADollar:
        return 'Fr';
      case CountryCurrency.CanadianDollar:
        return '\$';
      case CountryCurrency.CapeVerdeanEscudo:
        return 'Esc';
      case CountryCurrency.CentralAfricanCFADollar:
        return 'Fr';
      case CountryCurrency.ChileanPeso:
        return '\$';
      case CountryCurrency.ChineseYuan:
        return '¥';
      case CountryCurrency.ColombianPeso:
        return '\$';
      case CountryCurrency.ComorianFranc:
        return 'CF';
      case CountryCurrency.CongoleseFranc:
        return 'FC';
      case CountryCurrency.CostaRicanColon:
        return '₡';
      case CountryCurrency.CroatianKuna:
        return 'kn';
      case CountryCurrency.CubanPeso:
        return '\$';
      case CountryCurrency.CzechKoruna:
        return 'Kč';
      case CountryCurrency.DanishKrone:
        return 'kr.';
      case CountryCurrency.DjiboutianFranc:
        return 'Fdj';
      case CountryCurrency.DominicanPeso:
        return 'RD\$';
      case CountryCurrency.EastCaribbeanDollar:
        return 'EC\$';
      case CountryCurrency.EgyptianPound:
        return '£';
      case CountryCurrency.SalvadoranColon:
        return '\$';
      case CountryCurrency.EritreanNakfa:
        return 'Nfk';
      case CountryCurrency.EstonianEuro:
        return '€';
      case CountryCurrency.SwaziLilangeni:
        return 'E';
      case CountryCurrency.EthiopianBirr:
        return 'Br';
      case CountryCurrency.FijianDollar:
        return 'FJ\$';
      case CountryCurrency.FinnishEuro:
        return '€';
      case CountryCurrency.FrenchEuro:
        return '€';
      case CountryCurrency.GaboneseCentralAfricanCFADollar:
        return 'Fr';
      case CountryCurrency.GambianDalasi:
        return 'D';
      case CountryCurrency.GeorgianLari:
        return 'ლ';
      case CountryCurrency.GhanaianCedi:
        return 'GH₵';
      case CountryCurrency.GreekEuro:
        return '€';
      case CountryCurrency.GuatemalanQuetzal:
        return 'Q';
      case CountryCurrency.GuineanFranc:
        return 'Fr';
      case CountryCurrency.GuyaneseDollar:
        return 'GY\$';
      case CountryCurrency.HaitianGourde:
        return 'G';
      case CountryCurrency.HonduranLempira:
        return 'L';
      case CountryCurrency.HongKongDollar:
        return 'HK\$';
      case CountryCurrency.HungarianForint:
        return 'Ft';
      case CountryCurrency.IcelandicKrona:
        return 'kr';
      case CountryCurrency.IndianRupee:
        return '₹';
      case CountryCurrency.IndonesianRupiah:
        return 'Rp';
      case CountryCurrency.IranianRial:
        return '﷼';
      case CountryCurrency.IraqiDinar:
        return 'ع.د';
      case CountryCurrency.IsraeliNewShekel:
        return '₪';
      case CountryCurrency.ItalianEuro:
        return '€';
      case CountryCurrency.JamaicanDollar:
        return 'J\$';
      case CountryCurrency.JapaneseYen:
        return '¥';
      case CountryCurrency.JordanianDinar:
        return 'د.ا';
      case CountryCurrency.KazakhstaniTenge:
        return '₸';
      case CountryCurrency.KenyanShilling:
        return 'KSh';
      case CountryCurrency.KuwaitiDinar:
        return 'د.ك';
      case CountryCurrency.KyrgyzstaniSom:
        return 'som';
      case CountryCurrency.LaoKip:
        return '₭';
      case CountryCurrency.LatvianEuro:
        return '€';
      case CountryCurrency.LebanesePound:
        return '£';
      case CountryCurrency.LesothoLoti:
        return 'M';
      case CountryCurrency.LiberianDollar:
        return 'L\$';
      case CountryCurrency.LibyanDinar:
        return 'LD';
      case CountryCurrency.SwissFranc:
        return 'Fr';
      case CountryCurrency.LithuanianEuro:
        return '€';
      case CountryCurrency.LuxembourgishEuro:
        return '€';
      case CountryCurrency.MacanesePataca:
        return 'MOP\$';
      case CountryCurrency.MalagasyAriary:
        return 'Ar';
      case CountryCurrency.MalawianKwacha:
        return 'MK';
      case CountryCurrency.MalaysianRinggit:
        return 'RM';
      case CountryCurrency.MaldivianRufiyaa:
        return 'Rf';
      case CountryCurrency.MalianWestAfricanCFADollar:
        return 'Fr';
      case CountryCurrency.MauritanianOuguiya:
        return 'UM';
      case CountryCurrency.MauritianRupee:
        return 'Rs';
      case CountryCurrency.MexicanPeso:
        return '\$';
      case CountryCurrency.MoldovanLeu:
        return 'L';
      case CountryCurrency.MongolianTogrog:
        return '₮';
      case CountryCurrency.MoroccanDirham:
        return 'DH';
      case CountryCurrency.MozambicanMetical:
        return 'MT';
      case CountryCurrency.BurmeseKyat:
        return 'Ks';
      case CountryCurrency.NamibianDollar:
        return 'N\$';
      case CountryCurrency.NepaleseRupee:
        return 'रू';
      case CountryCurrency.DutchEuro:
        return '€';
      case CountryCurrency.NewZealandDollar:
        return '\$';
      case CountryCurrency.NicaraguanCordoba:
        return 'C\$';
      case CountryCurrency.NigerianNaira:
        return '₦';
      case CountryCurrency.NorthKoreanWon:
        return '₩';
      case CountryCurrency.MacedonianDenar:
        return 'ден';
      case CountryCurrency.NorwegianKrone:
        return 'kr';
      case CountryCurrency.OmaniRial:
        return 'ر.ع.';
      case CountryCurrency.PakistaniRupee:
        return 'Rs';
      case CountryCurrency.PanamanianBalboa:
        return 'B/.';
      case CountryCurrency.PapuaNewGuineanKina:
        return 'K';
      case CountryCurrency.ParaguayanGuarani:
        return '₲';
      case CountryCurrency.PeruvianSol:
        return 'S/';
      case CountryCurrency.PhilippinePeso:
        return '₱';
      case CountryCurrency.PolishZloty:
        return 'zł';
      case CountryCurrency.QatariRiyal:
        return 'ر.ق';
      case CountryCurrency.RomanianLeu:
        return 'lei';
      case CountryCurrency.RussianRuble:
        return '₽';
      case CountryCurrency.RwandanFranc:
        return 'FRw';
      case CountryCurrency.EastCaribbeanDollarSaintKittsAndNevis:
        return 'EC\$';
      case CountryCurrency.EastCaribbeanDollarSaintLucia:
        return 'EC\$';
      case CountryCurrency.EastCaribbeanDollarSaintVincentAndTheGrenadines:
        return 'EC\$';
      case CountryCurrency.SamoanTala:
        return 'WS\$';
      case CountryCurrency.SaoTomeAndPrincipeDobra:
        return 'Db';
      case CountryCurrency.SaudiRiyal:
        return 'ر.س';
      case CountryCurrency.WestAfricanCFADollarSenegal:
        return 'Fr';
      case CountryCurrency.SerbianDinar:
        return 'РСД';
      case CountryCurrency.SeychelloisRupee:
        return 'SR';
      case CountryCurrency.SierraLeoneanLeone:
        return 'Le';
      case CountryCurrency.SingaporeDollar:
        return '\$';
      case CountryCurrency.SlovakKoruna:
        return '€';
      case CountryCurrency.SlovenianTolar:
        return '€';
      case CountryCurrency.SolomonIslandsDollar:
        return 'SI\$';
      case CountryCurrency.SomaliShilling:
        return 'Sh';
      case CountryCurrency.SouthAfricanRand:
        return 'R';
      case CountryCurrency.SouthKoreanWon:
        return '₩';
      case CountryCurrency.SouthSudanesePound:
        return '£';
      case CountryCurrency.SpanishEuro:
        return '€';
      case CountryCurrency.SriLankanRupee:
        return 'Rs';
      case CountryCurrency.SudanesePound:
        return 'ج.س.';
      case CountryCurrency.SurinameseDollar:
        return '\$';
      case CountryCurrency.SwedishKrona:
        return 'kr';
      case CountryCurrency.SwissFrancLiechtenstein:
        return 'Fr';
      case CountryCurrency.SwissFrancSwitzerland:
        return 'Fr';
      case CountryCurrency.SyrianPound:
        return '£S';
      case CountryCurrency.NewTaiwanDollar:
        return 'NT\$';
      case CountryCurrency.TajikistaniSomoni:
        return 'ЅМ';
      case CountryCurrency.TanzanianShilling:
        return 'TSh';
      case CountryCurrency.ThaiBaht:
        return '฿';
      case CountryCurrency.WestAfricanCFADollarTogo:
        return 'Fr';
      case CountryCurrency.TonganPaanga:
        return 'T\$';
      case CountryCurrency.TrinidadAndTobagoDollar:
        return 'TT\$';
      case CountryCurrency.TunisianDinar:
        return 'DT';
      case CountryCurrency.TurkishLira:
        return '₺';
      case CountryCurrency.TurkmenistaniManat:
        return 'T';
      case CountryCurrency.TuvaluanAustralianDollar:
        return '\$';
      case CountryCurrency.UgandanShilling:
        return 'USh';
      case CountryCurrency.UkrainianHryvnia:
        return '₴';
      case CountryCurrency.UnitedArabEmiratesDirhamUnitedArabEmirates:
        return 'د.إ';
      case CountryCurrency.BritishPoundSterlingUnitedKingdom:
        return '£';
      case CountryCurrency.UnitedStatesDollarUnitedStates:
        return '\$';
      case CountryCurrency.UruguayanPeso:
        return '\$';
      case CountryCurrency.UzbekistaniSom:
        return 'so\'m';
      case CountryCurrency.VanuatuVatu:
        return 'VT';
      case CountryCurrency.VenezuelanBolvar:
        return 'Bs.S.';
      case CountryCurrency.VietnameseDong:
        return '₫';
      case CountryCurrency.YemeniRial:
        return '﷼';
      case CountryCurrency.ZambianKwacha:
        return 'ZK';
      case CountryCurrency.ZimbabweanDollar:
        return 'Z\$';
      default:
        return '';
    }
  }

  String getCountryName() {
    switch (this) {
      case CountryCurrency.AfghanAfghani:
        return 'Afghanistan';
      case CountryCurrency.AlbanianLek:
        return 'Albania';
      case CountryCurrency.AlgerianDinar:
        return 'Algeria';
      case CountryCurrency.AngolanKwanza:
        return 'Angola';
      case CountryCurrency.ArgentinePeso:
        return 'Argentina';
      case CountryCurrency.ArmenianDram:
        return 'Armenia';
      case CountryCurrency.AustralianDollar:
        return 'Australia';
      case CountryCurrency.AustrianEuro:
        return 'Austria';
      case CountryCurrency.AzerbaijaniManat:
        return 'Azerbaijan';
      case CountryCurrency.BahrainiDinar:
        return 'Bahrain';
      case CountryCurrency.BangladeshiTaka:
        return 'Bangladesh';
      case CountryCurrency.BarbadianDollar:
        return 'Barbados';
      case CountryCurrency.BelarusianRuble:
        return 'Belarus';
      case CountryCurrency.BelizeDollar:
        return 'Belize';
      case CountryCurrency.BeninWestAfricanCFADollar:
        return 'Benin';
      case CountryCurrency.BhutaneseNgultrum:
        return 'Bhutan';
      case CountryCurrency.BolivianBoliviano:
        return 'Bolivia';
      case CountryCurrency.BosniaHerzegovinaConvertibleMark:
        return 'Bosnia and Herzegovina';
      case CountryCurrency.BotswanaPula:
        return 'Botswana';
      case CountryCurrency.BrazilianReal:
        return 'Brazil';
      case CountryCurrency.BruneiDollar:
        return 'Brunei';
      case CountryCurrency.BulgarianLev:
        return 'Bulgaria';
      case CountryCurrency.BurundianFranc:
        return 'Burundi';
      case CountryCurrency.CambodianRiel:
        return 'Cambodia';
      case CountryCurrency.CameroonianCentralAfricanCFADollar:
        return 'Cameroon';
      case CountryCurrency.CanadianDollar:
        return 'Canada';
      case CountryCurrency.CapeVerdeanEscudo:
        return 'Cape Verde';
      case CountryCurrency.CentralAfricanCFADollar:
        return 'Central African Republic';
      case CountryCurrency.ChileanPeso:
        return 'Chile';
      case CountryCurrency.ChineseYuan:
        return 'China';
      case CountryCurrency.ColombianPeso:
        return 'Colombia';
      case CountryCurrency.ComorianFranc:
        return 'Comoros';
      case CountryCurrency.CongoleseFranc:
        return 'Congo (Democratic Republic)';
      case CountryCurrency.CostaRicanColon:
        return 'Costa Rica';
      case CountryCurrency.CroatianKuna:
        return 'Croatia';
      case CountryCurrency.CubanPeso:
        return 'Cuba';
      case CountryCurrency.CzechKoruna:
        return 'Czech Republic';
      case CountryCurrency.DanishKrone:
        return 'Denmark';
      case CountryCurrency.DjiboutianFranc:
        return 'Djibouti';
      case CountryCurrency.DominicanPeso:
        return 'Dominican Republic';
      case CountryCurrency.EastCaribbeanDollar:
        return 'East Caribbean States';
      case CountryCurrency.EgyptianPound:
        return 'Egypt';
      case CountryCurrency.SalvadoranColon:
        return 'El Salvador';
      case CountryCurrency.EritreanNakfa:
        return 'Eritrea';
      case CountryCurrency.EstonianEuro:
        return 'Estonia';
      case CountryCurrency.SwaziLilangeni:
        return 'Eswatini';
      case CountryCurrency.EthiopianBirr:
        return 'Ethiopia';
      case CountryCurrency.FijianDollar:
        return 'Fiji';
      case CountryCurrency.FinnishEuro:
        return 'Finland';
      case CountryCurrency.FrenchEuro:
        return 'France';
      case CountryCurrency.GaboneseCentralAfricanCFADollar:
        return 'Gabon';
      case CountryCurrency.GambianDalasi:
        return 'Gambia';
      case CountryCurrency.GeorgianLari:
        return 'Georgia';
      case CountryCurrency.GhanaianCedi:
        return 'Ghana';
      case CountryCurrency.GreekEuro:
        return 'Greece';
      case CountryCurrency.GuatemalanQuetzal:
        return 'Guatemala';
      case CountryCurrency.GuineanFranc:
        return 'Guinea';
      case CountryCurrency.GuyaneseDollar:
        return 'Guyana';
      case CountryCurrency.HaitianGourde:
        return 'Haiti';
      case CountryCurrency.HonduranLempira:
        return 'Honduras';
      case CountryCurrency.HongKongDollar:
        return 'Hong Kong';
      case CountryCurrency.HungarianForint:
        return 'Hungary';
      case CountryCurrency.IcelandicKrona:
        return 'Iceland';
      case CountryCurrency.IndianRupee:
        return 'India';
      case CountryCurrency.IndonesianRupiah:
        return 'Indonesia';
      case CountryCurrency.IranianRial:
        return 'Iran';
      case CountryCurrency.IraqiDinar:
        return 'Iraq';
      case CountryCurrency.IsraeliNewShekel:
        return 'Israel';
      case CountryCurrency.ItalianEuro:
        return 'Italy';
      case CountryCurrency.JamaicanDollar:
        return 'Jamaica';
      case CountryCurrency.JapaneseYen:
        return 'Japan';
      case CountryCurrency.JordanianDinar:
        return 'Jordan';
      case CountryCurrency.KazakhstaniTenge:
        return 'Kazakhstan';
      case CountryCurrency.KenyanShilling:
        return 'Kenya';
      case CountryCurrency.KuwaitiDinar:
        return 'Kuwait';
      case CountryCurrency.KyrgyzstaniSom:
        return 'Kyrgyzstan';
      case CountryCurrency.LaoKip:
        return 'Laos';
      case CountryCurrency.LatvianEuro:
        return 'Latvia';
      case CountryCurrency.LebanesePound:
        return 'Lebanon';
      case CountryCurrency.LesothoLoti:
        return 'Lesotho';
      case CountryCurrency.LiberianDollar:
        return 'Liberia';
      case CountryCurrency.LibyanDinar:
        return 'Libya';
      case CountryCurrency.SwissFranc:
        return 'Liechtenstein';
      case CountryCurrency.LithuanianEuro:
        return 'Lithuania';
      case CountryCurrency.LuxembourgishEuro:
        return 'Luxembourg';
      case CountryCurrency.MacanesePataca:
        return 'Macao';
      case CountryCurrency.MalagasyAriary:
        return 'Madagascar';
      case CountryCurrency.MalawianKwacha:
        return 'Malawi';
      case CountryCurrency.MalaysianRinggit:
        return 'Malaysia';
      case CountryCurrency.MaldivianRufiyaa:
        return 'Maldives';
      case CountryCurrency.MalianWestAfricanCFADollar:
        return 'Mali';
      case CountryCurrency.MauritanianOuguiya:
        return 'Mauritania';
      case CountryCurrency.MauritianRupee:
        return 'Mauritius';
      case CountryCurrency.MexicanPeso:
        return 'Mexico';
      case CountryCurrency.MoldovanLeu:
        return 'Moldova';
      case CountryCurrency.MongolianTogrog:
        return 'Mongolia';
      case CountryCurrency.MoroccanDirham:
        return 'Morocco';
      case CountryCurrency.MozambicanMetical:
        return 'Mozambique';
      case CountryCurrency.BurmeseKyat:
        return 'Myanmar';
      case CountryCurrency.NamibianDollar:
        return 'Namibia';
      case CountryCurrency.NepaleseRupee:
        return 'Nepal';
      case CountryCurrency.DutchEuro:
        return 'Netherlands';
      case CountryCurrency.NewZealandDollar:
        return 'New Zealand';
      case CountryCurrency.NicaraguanCordoba:
        return 'Nicaragua';
      case CountryCurrency.NigerianNaira:
        return 'Nigeria';
      case CountryCurrency.NorthKoreanWon:
        return 'North Korea';
      case CountryCurrency.MacedonianDenar:
        return 'North Macedonia';
      case CountryCurrency.NorwegianKrone:
        return 'Norway';
      case CountryCurrency.OmaniRial:
        return 'Oman';
      case CountryCurrency.PakistaniRupee:
        return 'Pakistan';
      case CountryCurrency.PanamanianBalboa:
        return 'Panama';
      case CountryCurrency.PapuaNewGuineanKina:
        return 'Papua New Guinea';
      case CountryCurrency.ParaguayanGuarani:
        return 'Paraguay';
      case CountryCurrency.PeruvianSol:
        return 'Peru';
      case CountryCurrency.PhilippinePeso:
        return 'Philippines';
      case CountryCurrency.PolishZloty:
        return 'Poland';
      case CountryCurrency.QatariRiyal:
        return 'Qatar';
      case CountryCurrency.RomanianLeu:
        return 'Romania';
      case CountryCurrency.RussianRuble:
        return 'Russia';
      case CountryCurrency.RwandanFranc:
        return 'Rwanda';
      case CountryCurrency.EastCaribbeanDollarSaintKittsAndNevis:
        return 'Saint Kitts and Nevis';
      case CountryCurrency.EastCaribbeanDollarSaintLucia:
        return 'Saint Lucia';
      case CountryCurrency.EastCaribbeanDollarSaintVincentAndTheGrenadines:
        return 'Saint Vincent and the Grenadines';
      case CountryCurrency.SamoanTala:
        return 'Samoa';
      case CountryCurrency.SaoTomeAndPrincipeDobra:
        return 'São Tomé and Príncipe';
      case CountryCurrency.SaudiRiyal:
        return 'Saudi Arabia';
      case CountryCurrency.WestAfricanCFADollarSenegal:
        return 'Senegal';
      case CountryCurrency.SerbianDinar:
        return 'Serbia';
      case CountryCurrency.SeychelloisRupee:
        return 'Seychelles';
      case CountryCurrency.SierraLeoneanLeone:
        return 'Sierra Leone';
      case CountryCurrency.SingaporeDollar:
        return 'Singapore';
      case CountryCurrency.SlovakKoruna:
        return 'Slovakia';
      case CountryCurrency.SlovenianTolar:
        return 'Slovenia';
      case CountryCurrency.SolomonIslandsDollar:
        return 'Solomon Islands';
      case CountryCurrency.SomaliShilling:
        return 'Somalia';
      case CountryCurrency.SouthAfricanRand:
        return 'South Africa';
      case CountryCurrency.SouthKoreanWon:
        return 'South Korea';
      case CountryCurrency.SouthSudanesePound:
        return 'South Sudan';
      case CountryCurrency.SpanishEuro:
        return 'Spain';
      case CountryCurrency.SriLankanRupee:
        return 'Sri Lanka';
      case CountryCurrency.SudanesePound:
        return 'Sudan';
      case CountryCurrency.SurinameseDollar:
        return 'Suriname';
      case CountryCurrency.SwedishKrona:
        return 'Sweden';
      case CountryCurrency.SwissFrancLiechtenstein:
        return 'Switzerland';
      case CountryCurrency.SwissFrancSwitzerland:
        return 'Switzerland';
      case CountryCurrency.SyrianPound:
        return 'Syria';
      case CountryCurrency.NewTaiwanDollar:
        return 'Taiwan';
      case CountryCurrency.TajikistaniSomoni:
        return 'Tajikistan';
      case CountryCurrency.TanzanianShilling:
        return 'Tanzania';
      case CountryCurrency.ThaiBaht:
        return 'Thailand';
      case CountryCurrency.WestAfricanCFADollarTogo:
        return 'Togo';
      case CountryCurrency.TonganPaanga:
        return 'Tonga';
      case CountryCurrency.TrinidadAndTobagoDollar:
        return 'Trinidad and Tobago';
      case CountryCurrency.TunisianDinar:
        return 'Tunisia';
      case CountryCurrency.TurkishLira:
        return 'Turkey';
      case CountryCurrency.TurkmenistaniManat:
        return 'Turkmenistan';
      case CountryCurrency.TuvaluanAustralianDollar:
        return 'Tuvalu';
      case CountryCurrency.UgandanShilling:
        return 'Uganda';
      case CountryCurrency.UkrainianHryvnia:
        return 'Ukraine';
      case CountryCurrency.UnitedArabEmiratesDirhamUnitedArabEmirates:
        return 'United Arab Emirates';
      case CountryCurrency.BritishPoundSterlingUnitedKingdom:
        return 'United Kingdom';
      case CountryCurrency.UnitedStatesDollarUnitedStates:
        return 'United States';
      case CountryCurrency.UruguayanPeso:
        return 'Uruguay';
      case CountryCurrency.UzbekistaniSom:
        return 'Uzbekistan';
      case CountryCurrency.VanuatuVatu:
        return 'Vanuatu';
      case CountryCurrency.VenezuelanBolvar:
        return 'Venezuela';
      case CountryCurrency.VietnameseDong:
        return 'Vietnam';
      case CountryCurrency.YemeniRial:
        return 'Yemen';
      case CountryCurrency.ZambianKwacha:
        return 'Zambia';
      case CountryCurrency.ZimbabweanDollar:
        return 'Zimbabwe';
      default:
        return '';
    }
  }

  String getCurrencyName() {
    switch (this) {
      case CountryCurrency.AfghanAfghani:
        return 'Afghan Afghani';
      case CountryCurrency.AlbanianLek:
        return 'Albanian Lek';
      case CountryCurrency.AlgerianDinar:
        return 'Algerian Dinar';
      case CountryCurrency.AngolanKwanza:
        return 'Angolan Kwanza';
      case CountryCurrency.ArgentinePeso:
        return 'Argentine Peso';
      case CountryCurrency.ArmenianDram:
        return 'Armenian Dram';
      case CountryCurrency.AustralianDollar:
        return 'Australian Dollar';
      case CountryCurrency.AustrianEuro:
        return 'Austrian Euro';
      case CountryCurrency.AzerbaijaniManat:
        return 'Azerbaijani Manat';
      case CountryCurrency.BahrainiDinar:
        return 'Bahraini Dinar';
      case CountryCurrency.BangladeshiTaka:
        return 'Bangladeshi Taka';
      case CountryCurrency.BarbadianDollar:
        return 'Barbadian Dollar';
      case CountryCurrency.BelarusianRuble:
        return 'Belarusian Ruble';
      case CountryCurrency.BelizeDollar:
        return 'Belize Dollar';
      case CountryCurrency.BeninWestAfricanCFADollar:
        return 'Benin West African CFA Franc';
      case CountryCurrency.BhutaneseNgultrum:
        return 'Bhutanese Ngultrum';
      case CountryCurrency.BolivianBoliviano:
        return 'Bolivian Boliviano';
      case CountryCurrency.BosniaHerzegovinaConvertibleMark:
        return 'Bosnia and Herzegovina Convertible Mark';
      case CountryCurrency.BotswanaPula:
        return 'Botswana Pula';
      case CountryCurrency.BrazilianReal:
        return 'Brazilian Real';
      case CountryCurrency.BruneiDollar:
        return 'Brunei Dollar';
      case CountryCurrency.BulgarianLev:
        return 'Bulgarian Lev';
      case CountryCurrency.BurundianFranc:
        return 'Burundian Franc';
      case CountryCurrency.CambodianRiel:
        return 'Cambodian Riel';
      case CountryCurrency.CameroonianCentralAfricanCFADollar:
        return 'Cameroonian Central African CFA Franc';
      case CountryCurrency.CanadianDollar:
        return 'Canadian Dollar';
      case CountryCurrency.CapeVerdeanEscudo:
        return 'Cape Verdean Escudo';
      case CountryCurrency.CentralAfricanCFADollar:
        return 'Central African CFA Franc';
      case CountryCurrency.ChileanPeso:
        return 'Chilean Peso';
      case CountryCurrency.ChineseYuan:
        return 'Chinese Yuan';
      case CountryCurrency.ColombianPeso:
        return 'Colombian Peso';
      case CountryCurrency.ComorianFranc:
        return 'Comorian Franc';
      case CountryCurrency.CongoleseFranc:
        return 'Congolese Franc';
      case CountryCurrency.CostaRicanColon:
        return 'Costa Rican Colón';
      case CountryCurrency.CroatianKuna:
        return 'Croatian Kuna';
      case CountryCurrency.CubanPeso:
        return 'Cuban Peso';
      case CountryCurrency.CzechKoruna:
        return 'Czech Koruna';
      case CountryCurrency.DanishKrone:
        return 'Danish Krone';
      case CountryCurrency.DjiboutianFranc:
        return 'Djiboutian Franc';
      case CountryCurrency.DominicanPeso:
        return 'Dominican Peso';
      case CountryCurrency.EastCaribbeanDollar:
        return 'East Caribbean Dollar';
      case CountryCurrency.EgyptianPound:
        return 'Egyptian Pound';
      case CountryCurrency.SalvadoranColon:
        return 'Salvadoran Colón';
      case CountryCurrency.EritreanNakfa:
        return 'Eritrean Nakfa';
      case CountryCurrency.EstonianEuro:
        return 'Estonian Euro';
      case CountryCurrency.SwaziLilangeni:
        return 'Swazi Lilangeni';
      case CountryCurrency.EthiopianBirr:
        return 'Ethiopian Birr';
      case CountryCurrency.FijianDollar:
        return 'Fijian Dollar';
      case CountryCurrency.FinnishEuro:
        return 'Finnish Euro';
      case CountryCurrency.FrenchEuro:
        return 'French Euro';
      case CountryCurrency.GaboneseCentralAfricanCFADollar:
        return 'Gabonese Central African CFA Franc';
      case CountryCurrency.GambianDalasi:
        return 'Gambian Dalasi';
      case CountryCurrency.GeorgianLari:
        return 'Georgian Lari';
      case CountryCurrency.GhanaianCedi:
        return 'Ghanaian Cedi';
      case CountryCurrency.GreekEuro:
        return 'Greek Euro';
      case CountryCurrency.GuatemalanQuetzal:
        return 'Guatemalan Quetzal';
      case CountryCurrency.GuineanFranc:
        return 'Guinean Franc';
      case CountryCurrency.GuyaneseDollar:
        return 'Guyanese Dollar';
      case CountryCurrency.HaitianGourde:
        return 'Haitian Gourde';
      case CountryCurrency.HonduranLempira:
        return 'Honduran Lempira';
      case CountryCurrency.HongKongDollar:
        return 'Hong Kong Dollar';
      case CountryCurrency.HungarianForint:
        return 'Hungarian Forint';
      case CountryCurrency.IcelandicKrona:
        return 'Icelandic Króna';
      case CountryCurrency.IndianRupee:
        return 'Indian Rupee';
      case CountryCurrency.IndonesianRupiah:
        return 'Indonesian Rupiah';
      case CountryCurrency.IranianRial:
        return 'Iranian Rial';
      case CountryCurrency.IraqiDinar:
        return 'Iraqi Dinar';
      case CountryCurrency.IsraeliNewShekel:
        return 'Israeli New Shekel';
      case CountryCurrency.ItalianEuro:
        return 'Italian Euro';
      case CountryCurrency.JamaicanDollar:
        return 'Jamaican Dollar';
      case CountryCurrency.JapaneseYen:
        return 'Japanese Yen';
      case CountryCurrency.JordanianDinar:
        return 'Jordanian Dinar';
      case CountryCurrency.KazakhstaniTenge:
        return 'Kazakhstani Tenge';
      case CountryCurrency.KenyanShilling:
        return 'Kenyan Shilling';
      case CountryCurrency.KuwaitiDinar:
        return 'Kuwaiti Dinar';
      case CountryCurrency.KyrgyzstaniSom:
        return 'Kyrgyzstani Som';
      case CountryCurrency.LaoKip:
        return 'Lao Kip';
      case CountryCurrency.LatvianEuro:
        return 'Latvian Euro';
      case CountryCurrency.LebanesePound:
        return 'Lebanese Pound';
      case CountryCurrency.LesothoLoti:
        return 'Lesotho Loti';
      case CountryCurrency.LiberianDollar:
        return 'Liberian Dollar';
      case CountryCurrency.LibyanDinar:
        return 'Libyan Dinar';
      case CountryCurrency.SwissFranc:
        return 'Swiss Franc';
      case CountryCurrency.LithuanianEuro:
        return 'Lithuanian Euro';
      case CountryCurrency.LuxembourgishEuro:
        return 'Luxembourgish Euro';
      case CountryCurrency.MacanesePataca:
        return 'Macanese Pataca';
      case CountryCurrency.MalagasyAriary:
        return 'Malagasy Ariary';
      case CountryCurrency.MalawianKwacha:
        return 'Malawian Kwacha';
      case CountryCurrency.MalaysianRinggit:
        return 'Malaysian Ringgit';
      case CountryCurrency.MaldivianRufiyaa:
        return 'Maldivian Rufiyaa';
      case CountryCurrency.MalianWestAfricanCFADollar:
        return 'Malian West African CFA Franc';
      case CountryCurrency.MauritanianOuguiya:
        return 'Mauritanian Ouguiya';
      case CountryCurrency.MauritianRupee:
        return 'Mauritian Rupee';
      case CountryCurrency.MexicanPeso:
        return 'Mexican Peso';
      case CountryCurrency.MoldovanLeu:
        return 'Moldovan Leu';
      case CountryCurrency.MongolianTogrog:
        return 'Mongolian Tögrög';
      case CountryCurrency.MoroccanDirham:
        return 'Moroccan Dirham';
      case CountryCurrency.MozambicanMetical:
        return 'Mozambican Metical';
      case CountryCurrency.BurmeseKyat:
        return 'Burmese Kyat';
      case CountryCurrency.NamibianDollar:
        return 'Namibian Dollar';
      case CountryCurrency.NepaleseRupee:
        return 'Nepalese Rupee';
      case CountryCurrency.DutchEuro:
        return 'Dutch Euro';
      case CountryCurrency.NewZealandDollar:
        return 'New Zealand Dollar';
      case CountryCurrency.NicaraguanCordoba:
        return 'Nicaraguan Córdoba';
      case CountryCurrency.NigerianNaira:
        return 'Nigerian Naira';
      case CountryCurrency.NorthKoreanWon:
        return 'North Korean Won';
      case CountryCurrency.MacedonianDenar:
        return 'Macedonian Denar';
      case CountryCurrency.NorwegianKrone:
        return 'Norwegian Krone';
      case CountryCurrency.OmaniRial:
        return 'Omani Rial';
      case CountryCurrency.PakistaniRupee:
        return 'Pakistani Rupee';
      case CountryCurrency.PanamanianBalboa:
        return 'Panamanian Balboa';
      case CountryCurrency.PapuaNewGuineanKina:
        return 'Papua New Guinean Kina';
      case CountryCurrency.ParaguayanGuarani:
        return 'Paraguayan Guaraní';
      case CountryCurrency.PeruvianSol:
        return 'Peruvian Sol';
      case CountryCurrency.PhilippinePeso:
        return 'Philippine Peso';
      case CountryCurrency.PolishZloty:
        return 'Polish Złoty';
      case CountryCurrency.QatariRiyal:
        return 'Qatari Riyal';
      case CountryCurrency.RomanianLeu:
        return 'Romanian Leu';
      case CountryCurrency.RussianRuble:
        return 'Russian Ruble';
      case CountryCurrency.RwandanFranc:
        return 'Rwandan Franc';
      case CountryCurrency.EastCaribbeanDollarSaintKittsAndNevis:
        return 'East Caribbean Dollar (Saint Kitts and Nevis)';
      case CountryCurrency.EastCaribbeanDollarSaintLucia:
        return 'East Caribbean Dollar (Saint Lucia)';
      case CountryCurrency.EastCaribbeanDollarSaintVincentAndTheGrenadines:
        return 'East Caribbean Dollar (Saint Vincent and the Grenadines)';
      case CountryCurrency.SamoanTala:
        return 'Samoan Tala';
      case CountryCurrency.SaoTomeAndPrincipeDobra:
        return 'São Tomé and Príncipe Dobra';
      case CountryCurrency.SaudiRiyal:
        return 'Saudi Riyal';
      case CountryCurrency.WestAfricanCFADollarSenegal:
        return 'West African CFA Franc (Senegal)';
      case CountryCurrency.SerbianDinar:
        return 'Serbian Dinar';
      case CountryCurrency.SeychelloisRupee:
        return 'Seychellois Rupee';
      case CountryCurrency.SierraLeoneanLeone:
        return 'Sierra Leonean Leone';
      case CountryCurrency.SingaporeDollar:
        return 'Singapore Dollar';
      case CountryCurrency.SlovakKoruna:
        return 'Slovak Koruna';
      case CountryCurrency.SlovenianTolar:
        return 'Slovenian Tolar';
      case CountryCurrency.SolomonIslandsDollar:
        return 'Solomon Islands Dollar';
      case CountryCurrency.SomaliShilling:
        return 'Somali Shilling';
      case CountryCurrency.SouthAfricanRand:
        return 'South African Rand';
      case CountryCurrency.SouthKoreanWon:
        return 'South Korean Won';
      case CountryCurrency.SouthSudanesePound:
        return 'South Sudanese Pound';
      case CountryCurrency.SpanishEuro:
        return 'Spanish Euro';
      case CountryCurrency.SriLankanRupee:
        return 'Sri Lankan Rupee';
      case CountryCurrency.SudanesePound:
        return 'Sudanese Pound';
      case CountryCurrency.SurinameseDollar:
        return 'Surinamese Dollar';
      case CountryCurrency.SwedishKrona:
        return 'Swedish Krona';
      case CountryCurrency.SwissFrancLiechtenstein:
        return 'Swiss Franc (Liechtenstein)';
      case CountryCurrency.SwissFrancSwitzerland:
        return 'Swiss Franc (Switzerland)';
      case CountryCurrency.SyrianPound:
        return 'Syrian Pound';
      case CountryCurrency.NewTaiwanDollar:
        return 'New Taiwan Dollar';
      case CountryCurrency.TajikistaniSomoni:
        return 'Tajikistani Somoni';
      case CountryCurrency.TanzanianShilling:
        return 'Tanzanian Shilling';
      case CountryCurrency.ThaiBaht:
        return 'Thai Baht';
      case CountryCurrency.WestAfricanCFADollarTogo:
        return 'West African CFA Franc (Togo)';
      case CountryCurrency.TonganPaanga:
        return 'Tongan Pa' 'anga';
      case CountryCurrency.TrinidadAndTobagoDollar:
        return 'Trinidad and Tobago Dollar';
      case CountryCurrency.TunisianDinar:
        return 'Tunisian Dinar';
      case CountryCurrency.TurkishLira:
        return 'Turkish Lira';
      case CountryCurrency.TurkmenistaniManat:
        return 'Turkmenistani Manat';
      case CountryCurrency.TuvaluanAustralianDollar:
        return 'Tuvaluan Dollar (Australian Dollar)';
      case CountryCurrency.UgandanShilling:
        return 'Ugandan Shilling';
      case CountryCurrency.UkrainianHryvnia:
        return 'Ukrainian Hryvnia';
      case CountryCurrency.UnitedArabEmiratesDirhamUnitedArabEmirates:
        return 'United Arab Emirates Dirham (United Arab Emirates)';
      case CountryCurrency.BritishPoundSterlingUnitedKingdom:
        return 'British Pound Sterling (United Kingdom)';
      case CountryCurrency.UnitedStatesDollarUnitedStates:
        return 'United States Dollar';
      case CountryCurrency.UruguayanPeso:
        return 'Uruguayan Peso';
      case CountryCurrency.UzbekistaniSom:
        return 'Uzbekistani Som';
      case CountryCurrency.VanuatuVatu:
        return 'Vanuatu Vatu';
      case CountryCurrency.VenezuelanBolvar:
        return 'Venezuelan Bolívar';
      case CountryCurrency.VietnameseDong:
        return 'Vietnamese Đồng';
      case CountryCurrency.YemeniRial:
        return 'Yemeni Rial';
      case CountryCurrency.ZambianKwacha:
        return 'Zambian Kwacha';
      case CountryCurrency.ZimbabweanDollar:
        return 'Zimbabwean Dollar';
      default:
        return '';
    }
  }
}
