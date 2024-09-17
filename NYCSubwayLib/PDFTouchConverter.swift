//
//  PDF:uchConverter.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 4/11/18.
//  Copyright © 2018 Thryv. All rights reserved.
//

import UIKit

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence
func ^^ (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}
func ^^ (radix: Double, power: Double) -> Double {
    return pow(radix, power)
}

public protocol PDFTouchConverter {
    var dots: [UIView] { get set }
    var distanceMetric: ((Int, Int), (Int, Int)) -> Double { get set }
    var fuzzyRadius: CGFloat { get set }
    var verticalScaleFactor: CGFloat { get set }
    var horizontalScaleFactor: CGFloat { get set }
    var verticalAdjustment: CGFloat { get set }
    var horizontalAdjustment: CGFloat { get set }
    static var coordToIdMap: [Two<Int, Int>: String] { get }
    func fuzzyCoordToId(coord: (Int, Int), fuzziness: Int) -> String?
}

func euclideanDistance(_ a: (Int, Int), _ b: (Int, Int)) -> Double {
    return sqrt(Double((a.0 - b.0) ^^ 2 + (a.1 - b.1) ^^ 2))
}

func euclideanDistance(_ a: (Double, Double), _ b: (Double, Double)) -> Double {
    return sqrt((a.0 - b.0) ^^ 2 + (a.1 - b.1) ^^ 2)
}

extension PDFTouchConverter {
    func addStopDots(to view: UIView, dots: inout [UIView]) {
        dots.forEach { $0.removeFromSuperview() }
        
        dots = []
        for coord in Self.coordToIdMap.keys {
            let x = view.bounds.size.width * (CGFloat(coord.values.0) + horizontalAdjustment) / horizontalScaleFactor
            let y = view.bounds.size.height * (CGFloat(coord.values.1) + verticalAdjustment) / verticalScaleFactor
            
            let dot = UIView(frame: CGRect(x: x, y: y, width: 1, height: 1))
            dot.backgroundColor = .red
            
            let radius: CGFloat = 30.0
            let frame = CGRect(x: Int(x) - Int(radius / 2),
                               y: Int(y) - Int(radius / 2), width: Int(radius), height: Int(radius))
            let tapZone = UILabel(frame: frame)
            tapZone.backgroundColor = UIColor.init(displayP3Red: 1.0, green: 0, blue: 0, alpha: 0.5)
            tapZone.layer.cornerRadius = tapZone.frame.size.height / 2
            tapZone.clipsToBounds = true
            tapZone.font = .systemFont(ofSize: 5)
            tapZone.text = Self.coordToIdMap[coord]
            tapZone.textAlignment = .center
            
            view.addSubview(tapZone)
            view.addConstraints(toSubview: tapZone, given: tapZone.frame)
            
            view.addSubview(dot)
            view.addConstraints(toSubview: dot, given: dot.frame)
            
            dots.append(dot)
            dots.append(tapZone)
        }
    }
}

extension UIView {
    func addConstraints(toSubview view: UIView, given frame: CGRect) {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: frame.origin.y),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: frame.origin.x)
        ])
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: frame.size.width))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: frame.size.height))
    }
}

class NYCNightPDFTouchConverter: NYCPDFTouchConverter {
    override init() {
        super.init()
        verticalAdjustment = 44 - 22
        horizontalAdjustment = 22 + 40
        horizontalScaleFactor = 4900
    }
}

class NYCPDFTouchConverter: PDFTouchConverter {
    var dots = [UIView]()
    var distanceMetric: ((Int, Int), (Int, Int)) -> Double = euclideanDistance
    public var fuzzyRadius: CGFloat = 30
    public var verticalScaleFactor: CGFloat = 5964
    public var horizontalScaleFactor: CGFloat = 4811
    public var verticalAdjustment: CGFloat = 44//12.0
    public var horizontalAdjustment: CGFloat = 22//7.0
    
    public func fuzzyCoordToId(coord: (Int, Int), fuzziness: Int) -> String? {
        var keys: [Two<Int, Int>] = Self.coordToIdMap.keys
            .filter({ distanceMetric($0.values, coord) < Double(fuzziness) })
        keys = keys.sorted(by: {
            return distanceMetric($0.values, coord) > distanceMetric($1.values, coord)
        })
        if (!keys.isEmpty) {
            return Self.coordToIdMap[keys.first!]
        } else {
            return nil
        }
    }
    
    public static let coordToIdMap: [Two<Int, Int>: String] = [
        Two(values: (752, 410)): "101",
        Two(values: (782, 548)): "103",
        Two(values: (776, 622)): "104",
        Two(values: (752, 690)): "106",
        Two(values: (554, 850)): "107",
        Two(values: (518, 926)): "108",
        Two(values: (482, 1012)): "109",
        Two(values: (466, 1076)): "110",
        Two(values: (450, 1166)): "111",
        Two(values: (448, 1368)): "112",
        Two(values: (448, 1504)): "113",
        Two(values: (446, 1646)): "114",
        Two(values: (446, 1736)): "115",
        Two(values: (444, 1824)): "116",
        Two(values: (444, 1918)): "117",
        Two(values: (456, 1996)): "118",
        Two(values: (470, 2118)): "119",
        Two(values: (470, 2226)): "120",
        Two(values: (470, 2326)): "121",
        Two(values: (470, 2418)): "122",
        Two(values: (486, 2510)): "123",
        Two(values: (520, 2604)): "124",
        Two(values: (604, 2738)): "125",
        Two(values: (730, 2876)): "126",
        Two(values: (796, 2968)): "127",
        Two(values: (784, 3068)): "128",
        Two(values: (784, 3140)): "129",
        Two(values: (784, 3202)): "130",
        Two(values: (784, 3262)): "131",
        Two(values: (784, 3328)): "132",
        Two(values: (796, 3466)): "133",
        Two(values: (852, 3600)): "134",
        Two(values: (894, 3712)): "135",
        Two(values: (904, 3776)): "136",
        Two(values: (912, 3848)): "137",
        Two(values: (914, 4046)): "138",
        Two(values: (918, 4136)): "139",
        Two(values: (1134, 4304)): "142",
        Two(values: (1502, 112)): "201",
        Two(values: (1500, 200)): "204",
        Two(values: (1498, 260)): "205",
        Two(values: (1500, 334)): "206",
        Two(values: (1512, 412)): "207",
        Two(values: (1546, 484)): "208",
        Two(values: (1606, 594)): "209",
        Two(values: (1646, 664)): "210",
        Two(values: (1700, 780)): "211",
        Two(values: (1710, 862)): "212",
        Two(values: (1686, 978)): "213",
        Two(values: (1616, 1032)): "214",
        Two(values: (1612, 1116)): "215",
        Two(values: (1622, 1232)): "216",
        Two(values: (1624, 1334)): "217",
        Two(values: (1608, 1412)): "218",
        Two(values: (1572, 1472)): "219",
        Two(values: (1498, 1530)): "220",
        Two(values: (1330, 1576)): "221",
        Two(values: (1238, 1562)): "222",
        Two(values: (934, 1752)): "224",
        Two(values: (932, 1844)): "225",
        Two(values: (934, 1920)): "226",
        Two(values: (932, 1998)): "227",
        Two(values: (1042, 3916)): "228",
        Two(values: (1176, 4006)): "229",
        Two(values: (1218, 4106)): "230",
        Two(values: (1806, 4046)): "231",
        Two(values: (1974, 4078)): "232",
        Two(values: (2094, 4068)): "233",
        Two(values: (2192, 4082)): "234",
        Two(values: (2314, 4124)): "235",
        Two(values: (2404, 4186)): "236",
        Two(values: (2482, 4220)): "237",
        Two(values: (2608, 4224)): "238",
        Two(values: (2692, 4182)): "239",
        Two(values: (2786, 4216)): "241",
        Two(values: (2830, 4264)): "242",
        Two(values: (2890, 4328)): "243",
        Two(values: (2952, 4392)): "244",
        Two(values: (2988, 4432)): "245",
        Two(values: (3028, 4474)): "246",
        Two(values: (3120, 4570)): "247",
        Two(values: (2808, 4124)): "248",
        Two(values: (2938, 4046)): "249",
        Two(values: (3058, 3966)): "250",
        Two(values: (3170, 3918)): "251",
        Two(values: (3290, 3870)): "252",
        Two(values: (3370, 3796)): "253",
        Two(values: (3424, 3748)): "254",
        Two(values: (3506, 3670)): "255",
        Two(values: (3556, 3624)): "256",
        Two(values: (3608, 3574)): "257",
        Two(values: (820, 1596)): "301",
        Two(values: (932, 1648)): "302",
        Two(values: (1216, 424)): "401",
        Two(values: (1212, 532)): "402",
        Two(values: (1202, 642)): "405",
        Two(values: (1182, 762)): "406",
        Two(values: (1168, 866)): "407",
        Two(values: (1166, 924)): "408",
        Two(values: (1168, 990)): "409",
        Two(values: (1168, 1070)): "410",
        Two(values: (1168, 1140)): "411",
        Two(values: (1168, 1210)): "412",
        Two(values: (1168, 1302)): "413",
        Two(values: (1184, 1438)): "414",
        Two(values: (1218, 1682)): "416",
        Two(values: (1114, 4106)): "419",
        Two(values: (1094, 4260)): "420",
        Two(values: (1802, 198)): "501",
        Two(values: (1798, 290)): "502",
        Two(values: (1790, 480)): "503",
        Two(values: (1786, 682)): "504",
        Two(values: (1778, 780)): "505",
        Two(values: (2210, 572)): "601",
        Two(values: (2204, 654)): "602",
        Two(values: (2180, 740)): "603",
        Two(values: (2128, 846)): "604",
        Two(values: (2070, 928)): "606",
        Two(values: (2016, 986)): "607",
        Two(values: (1954, 1044)): "608",
        Two(values: (1886, 1104)): "609",
        Two(values: (1812, 1174)): "610",
        Two(values: (1754, 1238)): "611",
        Two(values: (1730, 1298)): "612",
        Two(values: (1702, 1410)): "613",
        Two(values: (1690, 1486)): "614",
        Two(values: (1672, 1564)): "615",
        Two(values: (1648, 1632)): "616",
        Two(values: (1582, 1688)): "617",
        Two(values: (1462, 1708)): "618",
        Two(values: (1302, 1710)): "619",
        Two(values: (1200, 1844)): "621",
        Two(values: (1198, 1922)): "622",
        Two(values: (1198, 2002)): "623",
        Two(values: (1198, 2128)): "624",
        Two(values: (1198, 2212)): "625",
        Two(values: (1198, 2316)): "626",
        Two(values: (1198, 2462)): "627",
        Two(values: (1198, 2576)): "628",
        Two(values: (1198, 2734)): "629",
        Two(values: (1198, 2848)): "630",
        Two(values: (1186, 2968)): "631",
        Two(values: (1188, 3084)): "632",
        Two(values: (1186, 3138)): "633",
        Two(values: (1188, 3201)): "634",
        Two(values: (1187, 3306)): "635",
        Two(values: (1184, 3384)): "636",
        Two(values: (1210, 3548)): "637",
        Two(values: (1210, 3642)): "638",
        Two(values: (1180, 3734)): "639",
        Two(values: (1206, 3872)): "640",
        Two(values: (2900, 1890)): "701",
        Two(values: (2806, 2036)): "702",
        Two(values: (2752, 2120)): "705",
        Two(values: (2680, 2218)): "706",
        Two(values: (2624, 2270)): "707",
        Two(values: (2574, 2318)): "708",
        Two(values: (2484, 2394)): "709",
        Two(values: (2432, 2438)): "710",
        Two(values: (2330, 2524)): "711",
        Two(values: (2280, 2568)): "712",
        Two(values: (2216, 2616)): "713",
        Two(values: (2160, 2648)): "714",
        Two(values: (2058, 2692)): "715",
        Two(values: (1940, 2702)): "716",
        Two(values: (1762, 2682)): "718",
        Two(values: (1738, 2860)): "719",
        Two(values: (1746, 2980)): "720",
        Two(values: (1634, 2978)): "721",
        Two(values: (1086, 2976)): "724",
        Two(values: (466, 928)): "A02",
        Two(values: (400, 1010)): "A03",
        Two(values: (356, 1090)): "A05",
        Two(values: (344, 1168)): "A06",
        Two(values: (378, 1270)): "A07",
        Two(values: (498, 1426)): "A10",
        Two(values: (572, 1520)): "A11",
        Two(values: (596, 1644)): "A12",
        Two(values: (596, 1754)): "A14",
        Two(values: (596, 1836)): "A15",
        Two(values: (596, 1920)): "A16",
        Two(values: (596, 1996)): "A17",
        Two(values: (596, 2118)): "A18",
        Two(values: (596, 2224)): "A19",
        Two(values: (596, 2326)): "A20",
        Two(values: (596, 2396)): "A21",
        Two(values: (596, 2512)): "A22",
        Two(values: (592, 2878)): "A25",
        Two(values: (592, 2956)): "A27",
        Two(values: (592, 3072)): "A28",
        Two(values: (592, 3202)): "A30",
        Two(values: (602, 3312)): "A31",
        Two(values: (954, 3478)): "A32",
        Two(values: (958, 3642)): "A33",
        Two(values: (960, 3720)): "A34",
        Two(values: (970, 3848)): "A36",
        Two(values: (1832, 3926)): "A40",
        Two(values: (2006, 4032)): "A41",
        Two(values: (2134, 4148)): "A42",
        Two(values: (2308, 4048)): "A43",
        Two(values: (2422, 4006)): "A44",
        Two(values: (2592, 3934)): "A45",
        Two(values: (2682, 3880)): "A46",
        Two(values: (2754, 3828)): "A47",
        Two(values: (2900, 3724)): "A48",
        Two(values: (3004, 3644)): "A49",
        Two(values: (3102, 3572)): "A50",
        Two(values: (3206, 3478)): "A51",
        Two(values: (3394, 3500)): "A52",
        Two(values: (3472, 3492)): "A53",
        Two(values: (3564, 3442)): "A54",
        Two(values: (3634, 3372)): "A55",
        Two(values: (3696, 3292)): "A57",
        Two(values: (3744, 3194)): "A59",
        Two(values: (3794, 3120)): "A60",
        Two(values: (3840, 3078)): "A61",
        Two(values: (3946, 2990)): "A63",
        Two(values: (4016, 2928)): "A64",
        Two(values: (4088, 2866)): "A65",
        Two(values: (1710, 2638)): "B04",
        Two(values: (1478, 2638)): "B06",
        Two(values: (1182, 2638)): "B08",
        Two(values: (954, 2760)): "B10",
        Two(values: (2416, 4838)): "B12",
        Two(values: (2470, 4868)): "B13",
        Two(values: (2522, 4940)): "B14",
        Two(values: (2554, 4992)): "B15",
        Two(values: (2620, 5106)): "B16",
        Two(values: (2666, 5190)): "B17",
        Two(values: (2712, 5266)): "B18",
        Two(values: (2756, 5310)): "B19",
        Two(values: (2806, 5330)): "B20",
        Two(values: (2872, 5332)): "B21",
        Two(values: (2996, 5346)): "B22",
        Two(values: (3062, 5404)): "B23",
        Two(values: (1374, 524)): "D01",
        Two(values: (1250, 632)): "D03",
        Two(values: (1244, 744)): "D04",
        Two(values: (1242, 840)): "D05",
        Two(values: (1240, 932)): "D06",
        Two(values: (1244, 1018)): "D07",
        Two(values: (1242, 1102)): "D08",
        Two(values: (1244, 1206)): "D09",
        Two(values: (1238, 1302)): "D10",
        Two(values: (672, 1522)): "D12",
        Two(values: (760, 2822)): "D14",
        Two(values: (954, 2898)): "D15",
        Two(values: (954, 2990)): "D16",
        Two(values: (956, 3074)): "D17",
        Two(values: (954, 3202)): "D18",
        Two(values: (954, 3312)): "L02",
        Two(values: (1188, 3580)): "D21",
        Two(values: (1358, 3708)): "D22",
        Two(values: (2466, 4180)): "D25",
        Two(values: (2686, 4340)): "D26",
        Two(values: (2732, 4478)): "D27",
        Two(values: (2772, 4574)): "D28",
        Two(values: (2798, 4620)): "D29",
        Two(values: (2832, 4660)): "D30",
        Two(values: (2886, 4706)): "D31",
        Two(values: (2924, 4756)): "D32",
        Two(values: (3006, 4844)): "D33",
        Two(values: (3084, 4926)): "D34",
        Two(values: (3180, 5020)): "D35",
        Two(values: (3264, 5120)): "D37",
        Two(values: (3314, 5174)): "D38",
        Two(values: (3358, 5214)): "D39",
        Two(values: (3378, 5288)): "D40",
        Two(values: (3340, 5358)): "D41",
        Two(values: (3216, 5442)): "D42",
        Two(values: (3150, 5488)): "D43",
        Two(values: (978, 3968)): "E01",
        Two(values: (4152, 2188)): "F01",
        Two(values: (4080, 2268)): "F02",
        Two(values: (4024, 2334)): "F03",
        Two(values: (3958, 2404)): "F04",
        Two(values: (3814, 2494)): "F05",
        Two(values: (3658, 2498)): "F06",
        Two(values: (3480, 2502)): "F07",
        Two(values: (1706, 2818)): "F09",
        Two(values: (1226, 2820)): "F11",
        Two(values: (1100, 2820)): "F12",
        Two(values: (1368, 3578)): "F14",
        Two(values: (1466, 3668)): "F15",
        Two(values: (1494, 3730)): "F16",
        Two(values: (1920, 3810)): "F18",
        Two(values: (2020, 4242)): "F20",
        Two(values: (2022, 4318)): "F21",
        Two(values: (2104, 4378)): "F22",
        Two(values: (2228, 4372)): "F23",
        Two(values: (2422, 4388)): "F24",
        Two(values: (2500, 4438)): "F25",
        Two(values: (2620, 4618)): "F26",
        Two(values: (2654, 4714)): "F27",
        Two(values: (2732, 4816)): "F29",
        Two(values: (2772, 4856)): "F30",
        Two(values: (2816, 4902)): "F31",
        Two(values: (2870, 4960)): "F32",
        Two(values: (2970, 5064)): "F33",
        Two(values: (3000, 5098)): "F34",
        Two(values: (3042, 5142)): "F35",
        Two(values: (3132, 5236)): "F36",
        Two(values: (3198, 5306)): "F38",
        Two(values: (3236, 5352)): "F39",
        Two(values: (4162, 2498)): "G05",
        Two(values: (4084, 2578)): "G06",
        Two(values: (3896, 2558)): "G07",
        Two(values: (3232, 2498)): "G08",
        Two(values: (3094, 2496)): "G09",
        Two(values: (2952, 2510)): "G10",
        Two(values: (2790, 2524)): "G11",
        Two(values: (2664, 2528)): "G12",
        Two(values: (2528, 2508)): "G13",
        Two(values: (2438, 2502)): "G14",
        Two(values: (2328, 2460)): "G15",
        Two(values: (2204, 2440)): "G16",
        Two(values: (2088, 2434)): "G18",
        Two(values: (2000, 2452)): "G19",
        Two(values: (1908, 2584)): "G20",
        Two(values: (1804, 2734)): "G21",
        Two(values: (1718, 2948)): "G24",
        Two(values: (1876, 3196)): "G26",
        Two(values: (1968, 3268)): "G28",
        Two(values: (2070, 3360)): "G29",
        Two(values: (2230, 3496)): "G30",
        Two(values: (2330, 3580)): "G31",
        Two(values: (2436, 3672)): "G32",
        Two(values: (2510, 3802)): "G33",
        Two(values: (2434, 3882)): "G34",
        Two(values: (2366, 3952)): "G35",
        Two(values: (2292, 4028)): "G36",
        Two(values: (4040, 3358)): "H02",
        Two(values: (4080, 3488)): "H03",
        Two(values: (4286, 4130)): "H04",
        Two(values: (4486, 4222)): "H06",
        Two(values: (4530, 4160)): "H07",
        Two(values: (4576, 4114)): "H08",
        Two(values: (4620, 4050)): "H09",
        Two(values: (4642, 3976)): "H10",
        Two(values: (4648, 3930)): "H11",
        Two(values: (4380, 4414)): "H12",
        Two(values: (4352, 4498)): "H13",
        Two(values: (4310, 4578)): "H14",
        Two(values: (4268, 4654)): "H15",
        Two(values: (3796, 2738)): "J12",
        Two(values: (3732, 2802)): "J13",
        Two(values: (3660, 2876)): "J14",
        Two(values: (3572, 2960)): "J15",
        Two(values: (3514, 3020)): "J16",
        Two(values: (3462, 3070)): "J17",
        Two(values: (3432, 3148)): "J19",
        Two(values: (3462, 3218)): "J20",
        Two(values: (3454, 3284)): "J21",
        Two(values: (3410, 3340)): "J22",
        Two(values: (3358, 3386)): "J23",
        Two(values: (3280, 3446)): "J24",
        Two(values: (3052, 3480)): "J28",
        Two(values: (2964, 3484)): "J29",
        Two(values: (2876, 3490)): "J30",
        Two(values: (2742, 3498)): "J31",
        Two(values: (1316, 3314)): "L05",
        Two(values: (1396, 3312)): "L06",
        Two(values: (1870, 3312)): "L08",
        Two(values: (2076, 3324)): "L10",
        Two(values: (2188, 3304)): "L11",
        Two(values: (2270, 3312)): "L12",
        Two(values: (2360, 3346)): "L13",
        Two(values: (2438, 3346)): "L14",
        Two(values: (2592, 3266)): "L15",
        Two(values: (2688, 3262)): "L16",
        Two(values: (2828, 3268)): "L17",
        Two(values: (2952, 3282)): "L19",
        Two(values: (3044, 3354)): "L20",
        Two(values: (3120, 3420)): "L21",
        Two(values: (3280, 3546)): "L24",
        Two(values: (3408, 3666)): "L25",
        Two(values: (3488, 3742)): "L26",
        Two(values: (3542, 3802)): "L27",
        Two(values: (3592, 3892)): "L28",
        Two(values: (3616, 4042)): "L29",
        Two(values: (2892, 2940)): "M01",
        Two(values: (2892, 3034)): "M04",
        Two(values: (2886, 3086)): "M05",
        Two(values: (2872, 3156)): "M06",
        Two(values: (2782, 3338)): "M09",
        Two(values: (2716, 3404)): "M10",
        Two(values: (2586, 3498)): "M11",
        Two(values: (2376, 3510)): "M12",
        Two(values: (2304, 3514)): "M13",
        Two(values: (2194, 3522)): "M14",
        Two(values: (2064, 3532)): "M16",
        Two(values: (1318, 3678)): "M19",
        Two(values: (1234, 3848)): "M21",
        Two(values: (1176, 4170)): "M23",
        Two(values: (2336, 5078)): "N02",
        Two(values: (2444, 5078)): "N03",
        Two(values: (2552, 5078)): "N04",
        Two(values: (2770, 5078)): "N05",
        Two(values: (2828, 5082)): "N06",
        Two(values: (2898, 5116)): "N07",
        Two(values: (2958, 5176)): "N08",
        Two(values: (3080, 5294)): "N09",
        Two(values: (3116, 5332)): "N10",
        Two(values: (1842, 2102)): "R01",
        Two(values: (1842, 2218)): "R03",
        Two(values: (1842, 2322)): "R04",
        Two(values: (1840, 2430)): "R05",
        Two(values: (1836, 2534)): "R06",
        Two(values: (1818, 2616)): "R08",
        Two(values: (1230, 2720)): "R11",
        Two(values: (1122, 2718)): "R13",
        Two(values: (784, 2758)): "R14",
        Two(values: (782, 2886)): "R15",
        Two(values: (1032, 3140)): "R18",
        Two(values: (1100, 3204)): "R19",
        Two(values: (1160, 3378)): "R21",
        Two(values: (1158, 3610)): "R22",
        Two(values: (1102, 3870)): "R24",
        Two(values: (1022, 4046)): "R25",
        Two(values: (1012, 4136)): "R26",
        Two(values: (1156, 4286)): "R27",
        Two(values: (1948, 4060)): "R28",
        Two(values: (2196, 4014)): "R30",
        Two(values: (2250, 4174)): "R31",
        Two(values: (2242, 4282)): "R32",
        Two(values: (2240, 4516)): "R34",
        Two(values: (2238, 4626)): "R35",
        Two(values: (2242, 4774)): "R36",
        Two(values: (2236, 4858)): "R39",
        Two(values: (2232, 4952)): "R40",
        Two(values: (2232, 5028)): "R41",
        Two(values: (2232, 5148)): "R42",
        Two(values: (2244, 5230)): "R43",
        Two(values: (2270, 5316)): "R44",
        Two(values: (2292, 5386)): "R45",
        Two(values: (2640, 4128)): "S03",
        Two(values: (2666, 4238)): "S04",
        Two(values: (138, 5764)): "s09",
        Two(values: (150, 5730)): "s10",
        Two(values: (194, 5696)): "s12",
        Two(values: (274, 5664)): "s13",
        Two(values: (326, 5640)): "s14",
        Two(values: (400, 5586)): "s15",
        Two(values: (456, 5530)): "s16",
        Two(values: (518, 5468)): "s17",
        Two(values: (574, 5426)): "s18",
        Two(values: (692, 5354)): "s19",
        Two(values: (742, 5300)): "s20",
        Two(values: (784, 5224)): "s21",
        Two(values: (828, 5168)): "s22",
        Two(values: (868, 5118)): "s23",
        Two(values: (890, 5090)): "s24",
        Two(values: (920, 5042)): "s25",
        Two(values: (946, 4986)): "s26",
        Two(values: (960, 4934)): "s27",
        Two(values: (1038, 4776)): "s28",
        Two(values: (1014, 4728)): "s29",
        Two(values: (986, 4686)): "s30",
        Two(values: (978, 4632)): "s31",
        Two(values: (470, 3072)): "726",
        Two(values: (4044, 3292)): "H01",
        Two(values: (1296, 2516)): "Q03",
        Two(values: (1296, 2320)): "Q04",
        Two(values: (1296, 2212)): "Q05"
    ]
}

