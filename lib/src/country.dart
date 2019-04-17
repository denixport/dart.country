
///
class Country {
  // 'A' - 1
  static const _baseChar = 0x41 - 1;

  // code units buffer for alpha codes
  static final _a2cu = <int>[0, 0];
  static final _a3cu = <int>[0, 0, 0];

  // Country alphanumeric codes are packed into 35-bit unsigned integer
  // [0-9] Alpha-2 code, 5 bits per character
  // [10-24] Alpha-3 code, 5 bits per character
  // [25-35] int representing numeric code 0-999
  final int _code;

  const Country._(this._code);

  /// Creates user-assigned country
  factory Country.user(
      {String alpha2Code, String alpha3Code, int numericCode}) {
    assert(!(alpha2Code == null && alpha3Code == null && numericCode == null));

    int a2 = 0;
    int a3 = 0;

    // checks
    if (alpha2Code != null) {
      a2 = _packAlpha2(alpha2Code.codeUnits);
      if (!_isInRange(a2, _userA2Ranges)) {
        throw ArgumentError(
            "Alpha-2 code is not allowed for user-assignement \"alpha2Code\"");
      }
    }

    // alpha-2
    if (alpha3Code != null) {
      a3 = _packAlpha3(alpha3Code.codeUnits);
      if (!_isInRange(a3, _userA3Ranges)) {
        throw ArgumentError(
            "Alpha-3 code is not allowed for user-assignement \"alpha2Code\"");
      }
    }

    // numeric
    if (numericCode != null && (numericCode < 900 || numericCode > 999)) {
      throw ArgumentError.value(
          numericCode, "numericCode", "Should be between 900..999");
    }

    numericCode ??= 0;

    int code;
    if ((1 << 32) != 0) {
      code = a2 | a3 | numericCode;
    } else {
      code = a2 + (a3 | numericCode);
    }

    return Country._(code);
  }

  /// Alpha-2 code as defined in (ISO 3166-1)[https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2]
  String get alpha2Code {
    _unpackAlpha2(_code);
    return (_a2cu[0] != _baseChar) ? String.fromCharCodes(_a2cu) : "";
  }

  /// Alpha-3 code as defined in (ISO 3166-1)[https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3]
  String get alpha3Code {
    _unpackAlpha3(_code);
    return (_a3cu[0] != _baseChar) ? String.fromCharCodes(_a3cu) : "";
  }

  /// Numeric code as defined in (ISO 3166-1)[https://en.wikipedia.org/wiki/ISO_3166-1_numeric]
  int get numericCode {
    return _code & 0x3ff;
  }

  /// Returns `true` if it's a country with official ISO 3166-1 codes
  bool get isOfficial {
    int n = _code & 0x3ff;
    return n == 0 || n >= 900;
  }

  /// Returns `true` if it's a country with user-assigned codes.
  /// See (User-assigned code elements)[https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#User-assigned_code_elements]
  bool get isUserAssigned {
    int n = _code & 0x3ff;
    return n == 0 || n >= 900;
  }

  /// List of all user-assigned countries
  // TODO: optimize?
  static List<Country> get userValues => _userValues;

  /// Returns country by Alpha-2 or Alpha-3 code
  /// Throws `ArgumentError` if the [code] is invalid or there is no
  /// ISO- or user-assigned country for this [code]
  static Country ofAlphaCode(String code) {
    int index;

    if (_userValues.isNotEmpty) {
      index = _parseAlpha(code, _userValues);
      if (index != -1) {
        return _userValues[index];
      }
    }

    index = _parseAlpha(code, values);
    if (index != -1) {
      return values[index];
    }

    throw ArgumentError("No country assigned for alpha code \"$code\"");
  }

  /// Returns country by numeric code
  /// Throws `ArgumentError` if the numeric [code] is invalid or there is no
  /// ISO- or user-assigned country for this [code]
  static Country ofNumericCode(int code) {
    int index;
    if (_userValues.isNotEmpty) {
      index = _indexOfNum(code, _userValues);
      if (index != -1) {
        return _userValues[index];
      }
    }

    index = _indexOfNum(code, values);
    if (index != -1) {
      return values[index];
    }

    throw ArgumentError("No country assigned for numeric code \"$code\"");
  }

  // returns index of numeric code in values list
  static int _indexOfNum(int code, List<Country> values) {
    for (int i = 0; i < values.length; i++) {
      if (values[i]._code & 0x3ff == code) {
        return i;
      }
    }
    return -1;
  }

  /// Parses [source] as Alpha-2, alpha-3 or numeric country code
  /// The [source] must be either 2-3 ASCII uppercase letters of alpha code,
  /// or 2-3 digits of numeric code
  /// Throws `FormatException` if the code is not valid country code
  static Country parse(String source) {
    Country c = _parse(source);
    if (c == null) {
      throw FormatException("Invalid or not assigned code", source);
    }
    return c;
  }

  /// Parses [source] as Alpha-2, alpha-3 or numeric country code.
  /// Same as [parse] but returns `null` in case of invalid country code
  static Country tryParse(String source) {
    return _parse(source);
  }

  //
  static Country _parse(String code) {
    int index;

    // try user-assigned alpha code
    if (_userValues.isNotEmpty) {
      index = _parseAlpha(code, _userValues);
      if (index != -1) {
        return _userValues[index];
      }
    }

    // try ISO alpha code
    index = _parseAlpha(code, values);
    if (index != -1) {
      return values[index];
    }

    // try user numeric code
    if (_userValues.isNotEmpty) {
      index = _parseNum(code, _userValues);
      if (index != -1) {
        return _userValues[index];
      }
    }

    // try ISO numeric code
    index = _parseNum(code, values);
    if (index != -1) {
      return values[index];
    }

    return null;
  }

  // Parses alpha-2 or alpha-3 code, returns -1 for invalid or unassigned
  static int _parseAlpha(String code, List<Country> values) {
    var cu = code.codeUnits;
    switch (cu.length) {
      case 2:
        for (int i = 0; i < values.length; i++) {
          _unpackAlpha2(values[i]._code);
          if (_a2cu[0] == cu[0] && _a2cu[1] == cu[1]) {
            return i;
          }
        }
        break;
      case 3:
        for (int i = 0; i < values.length; i++) {
          _unpackAlpha3(values[i]._code);
          if (_a3cu[0] == cu[0] && _a3cu[1] == cu[1] && _a3cu[2] == cu[2]) {
            return i;
          }
        }
        break;
    }
    return -1;
  }

  // Parses numeric code, returns -1 for invalid or unassigned
  static int _parseNum(String code, List<Country> values) {
    int n = int.tryParse(code);
    if (n == null) {
      return -1;
    }
    for (int i = 0; i < values.length; i++) {
      if (values[i]._code & 0x3ff == n) {
        return i;
      }
    }
    return -1;
  }

  /// Assigns user-defined codes. Returns index of country value in [userValues]
  /// Codes could be any combination of Alpha-2, alpha-2, or numeric code. 
  /// Either one of 3 codes is required.
  /// After calling [assign] user-assigned codes are available through
  /// [parse], [tryParse], [ofAlphaCode], and [ofNumericCode] static methods.
  static int assign({String alpha2Code, String alpha3Code, int numericCode}) {
    assert(!(alpha2Code == null && alpha3Code == null && numericCode == null));

    // check Alpha-2
    if (alpha2Code != null &&
        (_parseAlpha(alpha2Code, _userValues) != -1 ||
            _parseAlpha(alpha2Code, values) != -1)) {
      throw ArgumentError("Alpha-2 code \"$alpha2Code\" is already assigned");
    }

    // check Alpha-3
    if (alpha3Code != null &&
        (_parseAlpha(alpha3Code, _userValues) != -1 ||
            _parseAlpha(alpha3Code, values) != -1)) {
      throw ArgumentError("Alpha-3 code \"$alpha3Code\" is already assigned");
    }

    // check numeric
    if (numericCode != null &&
        (_indexOfNum(numericCode, _userValues) != -1 ||
            _indexOfNum(numericCode, values) != -1)) {
      throw ArgumentError("Numeric code \"$numericCode\" is already assigned");
    }

    _userValues.add(Country.user(
        alpha2Code: alpha2Code,
        alpha3Code: alpha3Code,
        numericCode: numericCode));

    return _userValues.length - 1;
  }

  /// Removes all of user-assigned countries
  static void unassignAll() {
    _userValues.clear();
  }

  // pack/unpack rutines

  static int _packAlpha2(List<int> cu) {
    if ((1 << 32) != 0) {
      return (cu[0] - _baseChar) << 30 | (cu[1] - _baseChar) << 25;
    } else {
      return ((cu[0] - _baseChar) * 0x40000000) + ((cu[1] - _baseChar) << 25);
    }
  }

  // gets Alpha-2 code units from int
  static void _unpackAlpha2(int i) {
    // hack to avoid 32-bit truncating in JS
    if ((1 << 32) != 0) {
      _a2cu[0] = _baseChar + ((i >> 30));
    } else {
      _a2cu[0] = _baseChar + (i ~/ 0x40000000);
    }
    _a2cu[1] = _baseChar + ((i >> 25) & 0x1F);
  }

  static int _packAlpha3(List<int> cu) {
    return (cu[0] - _baseChar) << 20 |
        (cu[1] - _baseChar) << 15 |
        (cu[2] - _baseChar) << 10;
  }

  // gets Alpha-2 code units from int
  static void _unpackAlpha3(int i) {
    _a3cu[0] = _baseChar + ((i >> 20) & 0x1F);
    _a3cu[1] = _baseChar + ((i >> 15) & 0x1F);
    _a3cu[2] = _baseChar + ((i >> 10) & 0x1F);
  }

  static bool _isInRange(int code, List<int> ranges) {
    for (int i = 0; i < ranges.length - 1; i += 2) {
      if (code >= ranges[i] && code <= ranges[i + 1]) {
        return true;
      }
    }
    return false;
  }

  // ranges of user-assignable Alpha-2 codes
  static const _userA2Ranges = <int>[
    1107296256, 1107296256, // AA..AA //
    18689818624, 19126026240, // QM..QZ
    25803358208, 26642219008, // XA..XZ
    28789702656, 28789702656, // ZZ..ZZ
  ];

  // ranges of user-assignable Alpha-3 codes
  static const _userA3Ranges = <int>[
    1082368, 1107968, // AAA..AAZ //
    18252800, 18704384, // QMA..QZZ
    25199616, 26044416, // XAA..XZZ
    28115968, 28141568, // ZZA..ZZZ
  ];

  // User-assigned countries
  static final _userValues = <Country>[];

  //GENERATED:START
  /// Andorra AD AND 20
  static const AD = Country._(1209470996);

  /// United Arab Emirates AE ARE 784
  static const AE = Country._(1243158288);

  /// Afghanistan AF AFG 4
  static const AF = Country._(1276320772);

  /// Antigua and Barbuda AG ATG 28
  static const AG = Country._(1310333980);

  /// Anguilla AI AIA 660
  static const AI = Country._(1377076884);

  /// Albania AL ALB 8
  static const AL = Country._(1477838856);

  /// Armenia AM ARM 51
  static const AM = Country._(1511601203);

  /// Angola AO AGO 24
  static const AO = Country._(1578351640);

  /// Antarctica AQ ATA 10
  static const AQ = Country._(1645872138);

  /// Argentina AR ARG 32
  static const AR = Country._(1679367200);

  /// American Samoa AS ASM 16
  static const AS = Country._(1712960528);

  /// Austria AT AUT 40
  static const AT = Country._(1746587688);

  /// Australia AU AUS 36
  static const AU = Country._(1780141092);

  /// Aruba AW ABW 533
  static const AW = Country._(1846631957);

  /// Åland Islands AX ALA 248
  static const AX = Country._(1880491256);

  /// Azerbaijan AZ AZE 31
  static const AZ = Country._(1948062751);

  /// Bosnia and Herzegovina BA BIH 70
  static const BA = Country._(2183438406);

  /// Barbados BB BRB 52
  static const BB = Country._(2217281588);

  /// Bangladesh BD BGD 50
  static const BD = Country._(2284032050);

  /// Belgium BE BEL 56
  static const BE = Country._(2317529144);

  /// Burkina Faso BF BFA 854
  static const BF = Country._(2351105878);

  /// Bulgaria BG BGR 100
  static const BG = Country._(2384709732);

  /// Bahrain BH BHR 48
  static const BH = Country._(2418296880);

  /// Burundi BI BDI 108
  static const BI = Country._(2451711084);

  /// Benin BJ BEN 204
  static const BJ = Country._(2485303500);

  /// Saint Barthélemy BL BLM 652
  static const BL = Country._(2552641164);

  /// Bermuda BM BMU 60
  static const BM = Country._(2586235964);

  /// Brunei Darussalam BN BRN 96
  static const BN = Country._(2619947104);

  /// Bolivia (Plurinational State of) BO BOL 68
  static const BO = Country._(2653401156);

  /// Bonaire, Sint Eustatius and Saba BQ BES 535
  static const BQ = Country._(2720189975);

  /// Brazil BR BRA 76
  static const BR = Country._(2754151500);

  /// Bahamas BS BHS 44
  static const BS = Country._(2787396652);

  /// Bhutan BT BTN 64
  static const BT = Country._(2821339200);

  /// Bouvet Island BV BVT 74
  static const BV = Country._(2888519754);

  /// Botswana BW BWA 72
  static const BW = Country._(2922087496);

  /// Belarus BY BLR 112
  static const BY = Country._(2988853360);

  /// Belize BZ BLZ 84
  static const BZ = Country._(3022415956);

  /// Canada CA CAN 124
  static const CA = Country._(3257972860);

  /// Cocos (Keeling) Islands CC CCK 166
  static const CC = Country._(3325144230);

  /// Congo, Democratic Republic of the CD COD 180
  static const CD = Country._(3359084724);

  /// Central African Republic CF CAF 140
  static const CF = Country._(3425736844);

  /// Congo CG COG 178
  static const CG = Country._(3459751090);

  /// Switzerland CH CHE 756
  static const CH = Country._(3493074676);

  /// Côte d'Ivoire CI CIV 384
  static const CI = Country._(3526678912);

  /// Cook Islands CK COK 184
  static const CK = Country._(3593972920);

  /// Chile CL CHL 152
  static const CL = Country._(3627298968);

  /// Cameroon CM CMR 120
  static const CM = Country._(3661023352);

  /// China CN CHN 156
  static const CN = Country._(3694409884);

  /// Colombia CO COL 170
  static const CO = Country._(3728191658);

  /// Costa Rica CR CRI 188
  static const CR = Country._(3828950204);

  /// Cuba CU CUB 192
  static const CU = Country._(3929704640);

  /// Cabo Verde CV CPV 132
  static const CV = Country._(3963115652);

  /// Curaçao CW CUW 531
  static const CW = Country._(3996835347);

  /// Christmas Island CX CXR 162
  static const CX = Country._(4030482594);

  /// Cyprus CY CYP 196
  static const CY = Country._(4064067780);

  /// Czechia CZ CZE 203
  static const CZ = Country._(4097643723);

  /// Germany DE DEU 276
  static const DE = Country._(4467119380);

  /// Djibouti DJ DJI 262
  static const DJ = Country._(4635043078);

  /// Denmark DK DNK 208
  static const DK = Country._(4668730576);

  /// Dominica DM DMA 212
  static const DM = Country._(4735796436);

  /// Dominican Republic DO DOM 214
  static const DO = Country._(4802983126);

  /// Algeria DZ DZA 12
  static const DZ = Country._(5172429836);

  /// Ecuador EC ECU 218
  static const EC = Country._(5474735322);

  /// Estonia EE EST 233
  static const EE = Country._(5542367465);

  /// Egypt EG EGY 818
  static const EG = Country._(5609088818);

  /// Western Sahara EH ESH 732
  static const EH = Country._(5643018972);

  /// Eritrea ER ERI 232
  static const ER = Country._(5978531048);

  /// Spain ES ESP 724
  static const ES = Country._(6012125908);

  /// Ethiopia ET ETH 231
  static const ET = Country._(6045704423);

  /// Finland FI FIN 246
  static const FI = Country._(6751041782);

  /// Fiji FJ FJI 242
  static const FJ = Country._(6784623858);

  /// Falkland Islands (Malvinas) FK FLK 238
  static const FK = Country._(6818245870);

  /// Micronesia (Federated States of) FM FSM 583
  static const FM = Country._(6885586503);

  /// Faroe Islands FO FRO 234
  static const FO = Country._(6952664298);

  /// France FR FRA 250
  static const FR = Country._(7053313274);

  /// Gabon GA GAB 266
  static const GA = Country._(7557122314);

  /// United Kingdom of Great Britain and Northern Ireland GB GBR 826
  static const GB = Country._(7590726458);

  /// Grenada GD GRD 308
  static const GD = Country._(7658344756);

  /// Georgia GE GEO 268
  static const GE = Country._(7691484428);

  /// French Guiana GF GUF 254
  static const GF = Country._(7725553918);

  /// Guernsey GG GGY 831
  static const GG = Country._(7758669631);

  /// Ghana GH GHA 288
  static const GH = Country._(7792231712);

  /// Gibraltar GI GIB 292
  static const GI = Country._(7825819940);

  /// Greenland GL GRL 304
  static const GL = Country._(7926788400);

  /// Gambia GM GMB 270
  static const GM = Country._(7960168718);

  /// Guinea GN GIN 324
  static const GN = Country._(7993604420);

  /// Guadeloupe GP GLP 312
  static const GP = Country._(8060813624);

  /// Equatorial Guinea GQ GNQ 226
  static const GQ = Country._(8094434530);

  /// Greece GR GRC 300
  static const GR = Country._(8128105772);

  /// South Georgia and the South Sandwich Islands GS SGS 239
  static const GS = Country._(8173898991);

  /// Guatemala GT GTM 320
  static const GT = Country._(8195290432);

  /// Guam GU GUM 316
  static const GU = Country._(8228877628);

  /// Guinea-Bissau GW GNB 624
  static const GW = Country._(8295746160);

  /// Guyana GY GUY 328
  static const GY = Country._(8363107656);

  /// Hong Kong HK HKG 344
  static const HK = Country._(8967789912);

  /// Heard Island and McDonald Islands HM HMD 334
  static const HM = Country._(9034961230);

  /// Honduras HN HND 340
  static const HN = Country._(9068548436);

  /// Croatia HR HRV 191
  static const HR = Country._(9202915519);

  /// Haiti HT HTI 332
  static const HT = Country._(9270076748);

  /// Hungary HU HUN 348
  static const HU = Country._(9303669084);

  /// Indonesia ID IDN 360
  static const ID = Country._(9807477096);

  /// Ireland IE IRL 372
  static const IE = Country._(9841488244);

  /// Israel IL ISR 376
  static const IL = Country._(10076408184);

  /// Isle of Man IM IMN 833
  static const IM = Country._(10109762369);

  /// India IN IND 356
  static const IN = Country._(10143338852);

  /// British Indian Ocean Territory IO IOT 86
  static const IO = Country._(10176942166);

  /// Iraq IQ IRQ 368
  static const IQ = Country._(10244146544);

  /// Iran (Islamic Republic of) IR IRN 364
  static const IR = Country._(10277697900);

  /// Iceland IS ISL 352
  static const IS = Country._(10311283040);

  /// Italy IT ITA 380
  static const IT = Country._(10344859004);

  /// Jersey JE JEY 832
  static const JE = Country._(10915866432);

  /// Jamaica JM JAM 388
  static const JM = Country._(11184158084);

  /// Jordan JO JOR 400
  static const JO = Country._(11251730832);

  /// Japan JP JPN 392
  static const JP = Country._(11285313928);

  /// Kenya KE KEN 404
  static const KE = Country._(11990645140);

  /// Kyrgyzstan KG KGZ 417
  static const KG = Country._(12057831841);

  /// Cambodia KH KHM 116
  static const KH = Country._(12091405428);

  /// Kiribati KI KIR 296
  static const KI = Country._(12124997928);

  /// Comoros KM COM 174
  static const KM = Country._(12251018414);

  /// Saint Kitts and Nevis KN KNA 659
  static const KN = Country._(12292916883);

  /// Korea (Democratic People's Republic of) KP PRK 408
  static const KP = Country._(12365409688);

  /// Korea, Republic of KR KOR 410
  static const KR = Country._(12427184538);

  /// Kuwait KW KWT 414
  static const KW = Country._(12595220894);

  /// Cayman Islands KY CYM 136
  static const KY = Country._(12653999240);

  /// Kazakhstan KZ KAZ 398
  static const KZ = Country._(12695169422);

  /// Lao People's Democratic Republic LA LAO 418
  static const LA = Country._(12931087778);

  /// Lebanon LB LBN 422
  static const LB = Country._(12964673958);

  /// Saint Lucia LC LCA 662
  static const LC = Country._(12998248086);

  /// Liechtenstein LI LIE 438
  static const LI = Country._(13199775158);

  /// Sri Lanka LK LKA 144
  static const LK = Country._(13266945168);

  /// Liberia LR LBR 430
  static const LR = Country._(13501548974);

  /// Lesotho LS LSO 426
  static const LS = Country._(13535657386);

  /// Lithuania LT LTU 440
  static const LT = Country._(13569250744);

  /// Luxembourg LU LUX 442
  static const LU = Country._(13602841018);

  /// Latvia LV LVA 428
  static const LV = Country._(13636404652);

  /// Libya LY LBY 434
  static const LY = Country._(13736437170);

  /// Morocco MA MAR 504
  static const MA = Country._(14005881336);

  /// Monaco MC MCO 492
  static const MC = Country._(14073052652);

  /// Moldova, Republic of MD MDA 498
  static const MD = Country._(14106625522);

  /// Montenegro ME MNE 499
  static const ME = Country._(14140511731);

  /// Saint Martin (French part) MF MAF 663
  static const MF = Country._(14173641367);

  /// Madagascar MG MDG 450
  static const MG = Country._(14207294914);

  /// Marshall Islands MH MHL 584
  static const MH = Country._(14240985672);

  /// North Macedonia MK MKD 807
  static const MK = Country._(14341739303);

  /// Mali ML MLI 466
  static const ML = Country._(14375331282);

  /// Myanmar MM MMR 104
  static const MM = Country._(14408927336);

  /// Mongolia MN MNG 496
  static const MN = Country._(14442503664);

  /// Macao MO MAC 446
  static const MO = Country._(14475627966);

  /// Northern Mariana Islands MP MNP 580
  static const MP = Country._(14509621828);

  /// Martinique MQ MTQ 474
  static const MQ = Country._(14543373786);

  /// Mauritania MR MRT 478
  static const MR = Country._(14576865758);

  /// Montserrat MS MSR 500
  static const MS = Country._(14610450932);

  /// Malta MT MLT 470
  static const MT = Country._(14643778006);

  /// Mauritius MU MUS 480
  static const MU = Country._(14677626336);

  /// Maldives MV MDV 462
  static const MV = Country._(14710626766);

  /// Malawi MW MWI 454
  static const MW = Country._(14744790470);

  /// Mexico MX MEX 484
  static const MX = Country._(14777770468);

  /// Malaysia MY MYS 458
  static const MY = Country._(14811975114);

  /// Mozambique MZ MOZ 508
  static const MZ = Country._(14845209084);

  /// Namibia NA NAM 516
  static const NA = Country._(15080666628);

  /// New Caledonia NC NCL 540
  static const NC = Country._(15147840028);

  /// Niger NE NER 562
  static const NE = Country._(15215020594);

  /// Norfolk Island NF NFK 574
  static const NF = Country._(15248600638);

  /// Nigeria NG NGA 566
  static const NG = Country._(15282177590);

  /// Nicaragua NI NIC 558
  static const NI = Country._(15349354030);

  /// Netherlands NL NLD 528
  static const NL = Country._(15450116624);

  /// Norway NO NOR 578
  static const NO = Country._(15550892610);

  /// Nepal NP NPL 524
  static const NP = Country._(15584473612);

  /// Nauru NR NRU 520
  static const NR = Country._(15651657224);

  /// Niue NU NIU 570
  static const NU = Country._(15752025658);

  /// New Zealand NZ NZL 554
  static const NZ = Country._(15920345642);

  /// Oman OM OMN 512
  static const OM = Country._(16558504448);

  /// Panama PA PAN 591
  static const PA = Country._(17230248527);

  /// Peru PE PER 604
  static const PE = Country._(17364601436);

  /// French Polynesia PF PYF 258
  static const PF = Country._(17398798594);

  /// Papua New Guinea PG PNG 598
  static const PG = Country._(17431993942);

  /// Philippines PH PHL 608
  static const PH = Country._(17465356896);

  /// Pakistan PK PAK 586
  static const PK = Country._(17565789770);

  /// Poland PL POL 616
  static const PL = Country._(17599804008);

  /// Saint Pierre and Miquelon PM SPM 666
  static const PM = Country._(17636538010);

  /// Pitcairn PN PCN 612
  static const PN = Country._(17666521700);

  /// Puerto Rico PR PRI 630
  static const PR = Country._(17801225846);

  /// Palestine, State of PS PSE 275
  static const PS = Country._(17834808595);

  /// Portugal PT PRT 620
  static const PT = Country._(17868345964);

  /// Palau PW PLW 585
  static const PW = Country._(17968815689);

  /// Paraguay PY PRY 600
  static const PY = Country._(18036123224);

  /// Qatar QA QAT 634
  static const QA = Country._(18305045114);

  /// Réunion RE REU 638
  static const RE = Country._(19514185342);

  /// Romania RO ROU 642
  static const RO = Country._(19850057346);

  /// Serbia RS SRB 688
  static const RS = Country._(19985402544);

  /// Russian Federation RU RUS 643
  static const RU = Country._(20051578499);

  /// Rwanda RW RWA 646
  static const RW = Country._(20118734470);

  /// Saudi Arabia SA SAU 682
  static const SA = Country._(20454626986);

  /// Solomon Islands SB SLB 90
  static const SB = Country._(20488521818);

  /// Seychelles SC SYC 690
  static const SC = Country._(20522503858);

  /// Sudan SD SDN 729
  static const SD = Country._(20555381465);

  /// Sweden SE SWE 752
  static const SE = Country._(20589549296);

  /// Singapore SG SGP 702
  static const SG = Country._(20656145086);

  /// Saint Helena, Ascension and Tristan da Cunha SH SHN 654
  static const SH = Country._(20689730190);

  /// Slovenia SI SVN 705
  static const SI = Country._(20723743425);

  /// Svalbard and Jan Mayen SJ SJM 744
  static const SJ = Country._(20756903656);

  /// Slovakia SK SVK 703
  static const SK = Country._(20790849215);

  /// Sierra Leone SL SLE 694
  static const SL = Country._(20824069814);

  /// San Marino SM SMR 674
  static const SM = Country._(20857670306);

  /// Senegal SN SEN 686
  static const SN = Country._(20890958510);

  /// Somalia SO SOM 706
  static const SO = Country._(20924839618);

  /// Suriname SR SUR 740
  static const SR = Country._(21025704676);

  /// South Sudan SS SSD 728
  static const SS = Country._(21059179224);

  /// Sao Tome and Principe ST STP 678
  static const ST = Country._(21092778662);

  /// El Salvador SV SLV 222
  static const SV = Country._(21159631070);

  /// Sint Maarten (Dutch part) SX SXM 534
  static const SX = Country._(21227124246);

  /// Syrian Arab Republic SY SYR 760
  static const SY = Country._(21260716792);

  /// Eswatini SZ SWZ 748
  static const SZ = Country._(21294213868);

  /// Turks and Caicos Islands TC TCA 796
  static const TC = Country._(21596571420);

  /// Chad TD TCD 148
  static const TD = Country._(21630128276);

  /// French Southern Territories TF ATF 260
  static const TF = Country._(21677873412);

  /// Togo TG TGO 768
  static const TG = Country._(21730934528);

  /// Thailand TH THA 764
  static const TH = Country._(21764507388);

  /// Tajikistan TJ TJK 762
  static const TJ = Country._(21831692026);

  /// Tokelau TK TKL 772
  static const TK = Country._(21865280260);

  /// Timor-Leste TL TLS 626
  static const TL = Country._(21898874482);

  /// Turkmenistan TM TKM 795
  static const TM = Country._(21932390171);

  /// Tunisia TN TUN 788
  static const TN = Country._(21966273300);

  /// Tonga TO TON 776
  static const TO = Country._(21999631112);

  /// Turkey TR TUR 792
  static const TR = Country._(22100495128);

  /// Trinidad and Tobago TT TTO 780
  static const TT = Country._(22167568140);

  /// Tuvalu TV TUV 798
  static const TV = Country._(22234716958);

  /// Taiwan, Province of China TW TWN 158
  static const TW = Country._(22268328094);

  /// Tanzania, United Republic of TZ TZA 834
  static const TZ = Country._(22369077058);

  /// Ukraine UA UKR 804
  static const UA = Country._(22604532516);

  /// Uganda UG UGA 800
  static const UG = Country._(22805710624);

  /// United States Minor Outlying Islands UM UMI 581
  static const UM = Country._(23007241797);

  /// United States of America US USA 840
  static const US = Country._(23208757064);

  /// Uruguay UY URY 858
  static const UY = Country._(23410075482);

  /// Uzbekistan UZ UZB 860
  static const UZ = Country._(23443868508);

  /// Holy See VA VAT 336
  static const VA = Country._(23678996816);

  /// Saint Vincent and the Grenadines VC VCT 670
  static const VC = Country._(23746171550);

  /// Venezuela (Bolivarian Republic of) VE VEN 862
  static const VE = Country._(23813339998);

  /// Virgin Islands (British) VG VGB 92
  static const VG = Country._(23880501340);

  /// Virgin Islands (U.S.) VI VIR 850
  static const VI = Country._(23947692882);

  /// Viet Nam VN VNM 704
  static const VN = Country._(24115623616);

  /// Vanuatu VU VUT 548
  static const VU = Country._(24350741028);

  /// Wallis and Futuna WF WLF 876
  static const WF = Country._(24921906028);

  /// Samoa WS WSM 882
  static const WS = Country._(25358350194);

  /// Yemen YE YEM 887
  static const YE = Country._(27037710199);

  /// Mayotte YT MYT 175
  static const YT = Country._(27529105583);

  /// South Africa ZA ZAF 710
  static const ZA = Country._(27978144454);

  /// Zambia ZM ZMB 894
  static const ZM = Country._(28381186942);

  /// Zimbabwe ZW ZWE 716
  static const ZW = Country._(28717061836);

  /// List of ISO standard values
  static const values = <Country>[
    AD, AE, AF, AG, AI, AL, AM, AO, AQ, AR, AS, AT, AU, AW, AX, AZ, BA, BB, //
    BD, BE, BF, BG, BH, BI, BJ, BL, BM, BN, BO, BQ, BR, BS, BT, BV, BW, BY,
    BZ, CA, CC, CD, CF, CG, CH, CI, CK, CL, CM, CN, CO, CR, CU, CV, CW, CX,
    CY, CZ, DE, DJ, DK, DM, DO, DZ, EC, EE, EG, EH, ER, ES, ET, FI, FJ, FK,
    FM, FO, FR, GA, GB, GD, GE, GF, GG, GH, GI, GL, GM, GN, GP, GQ, GR, GS,
    GT, GU, GW, GY, HK, HM, HN, HR, HT, HU, ID, IE, IL, IM, IN, IO, IQ, IR,
    IS, IT, JE, JM, JO, JP, KE, KG, KH, KI, KM, KN, KP, KR, KW, KY, KZ, LA,
    LB, LC, LI, LK, LR, LS, LT, LU, LV, LY, MA, MC, MD, ME, MF, MG, MH, MK,
    ML, MM, MN, MO, MP, MQ, MR, MS, MT, MU, MV, MW, MX, MY, MZ, NA, NC, NE,
    NF, NG, NI, NL, NO, NP, NR, NU, NZ, OM, PA, PE, PF, PG, PH, PK, PL, PM,
    PN, PR, PS, PT, PW, PY, QA, RE, RO, RS, RU, RW, SA, SB, SC, SD, SE, SG,
    SH, SI, SJ, SK, SL, SM, SN, SO, SR, SS, ST, SV, SX, SY, SZ, TC, TD, TF,
    TG, TH, TJ, TK, TL, TM, TN, TO, TR, TT, TV, TW, TZ, UA, UG, UM, US, UY,
    UZ, VA, VC, VE, VG, VI, VN, VU, WF, WS, YE, YT, ZA, ZM, ZW,
  ];
  //GENERATED:END
}
