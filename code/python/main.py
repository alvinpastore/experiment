
class PriceBar:
    _setsize = 0                            # don t forget to reinitialise before creating a new set of PriceBars with PriceBar.reset_id()

    def __init__(self, time = "", o = 0.0, c = 0.0, h = 0.0, l = 0.0):
        self._time = time                   # time data
        self._open = o                      # bar open
        self._close = c                     # bar close
        self._hi = h                        # bar high
        self._lo = l                        # bar low
        self._size = h - l                  # bar size
        self._way = c - o                   # > 0 means up bar, < 0 means down bar
        self._true_hi = 0                   # true hi init
        self._true_lo = 0                   # true lo init
        self._id = PriceBar._setsize        # bar number in the set
        PriceBar._setsize += 1

    def reset_id():
        PriceBar._setsize = 0

    def __str__(self):
        return "%s open: %f, close: %f, hi: %f, lo: %f, bar size is %f, way is %d\n" % (self._time, self._open, self._close, self._hi, self._lo, self._size, self._way)

    # used to populate the trues if called on the data set of PriceBars
    def set_trues(self, previous_bar):
        if (self._hi < previous_bar._close):
            self._true_hi = previous_bar._close
        if (self._lo > previous_bar._close):
            self._true_lo = previous_bar._close

    # must be used to get the high (in order to take into account the true high)
    def high(self):
        if self._true_hi == 0:
            return self._hi
        else:
            return self._true_hi

    # must be used to get the low (in order to take into account the true low)
    def low(self):
        if self._true_lo == 0:
            return self._lo
        else:
            return self._true_lo
    

class dataset:

    def __init__(self, data):
        self._data = []
        self._data = data

    def calculate_trues(self):
        size = len(self._data)
        if size < 2:
            return
        i = 1
        while i < size:
            self._data[i].set_trues(self._data[i - 1])
            i += 1

    def get_demand_tdpoints(self, level = 1):
        size = len(self._data)
        result = []
        
        if 0 == level or size < (level * 2 + 1):
            return result
        
        if 1 == level:
            i = 0
            
            while i < size - 2:
                i += 1
                if self._data[i]._lo >= self._data[i - 1].low():
                    continue
                if self._data[i]._lo < self._data[i + 1].low():                        
                    result.append(self._data[i])
       
            return result

        temp = self.get_demand_tdpoints(level - 1)
        if [] == temp:
            return []
        for point in temp:
            i = point._id
            if i - level < 0 or point._lo >= self._data[i - level].low():
                continue
                
            if i + level < size and point._lo < self._data[i + level].low():
                result.append(point)
            
        return result
         
    def get_supply_tdpoints(self, level = 1):
        size = len(self._data)
        result = []
        
        if 0 == level or size < (level * 2 + 1):
            return result
        
        if 1 == level:
            i = 0
            
            while i < size - 2:
                i += 1
                if self._data[i]._hi <= self._data[i - 1].high():
                    continue
                if self._data[i]._hi > self._data[i + 1].high():                        
                    result.append(self._data[i])
       
            return result

        temp = self.get_supply_tdpoints(level - 1)
        if [] == temp:
            return []
        for point in temp:
            i = point._id
            if i - level < 0 or point._hi <= self._data[i - level].high():
                continue
                
            if i + level < size and point._hi > self._data[i + level].high():
                result.append(point)
            
        return result


data_set = [ PriceBar("28/09/2016",1.1216,1.1212,1.1237,1.1182),
PriceBar("27/09/2016",1.1251,1.1215,1.1262,1.1188),
PriceBar("26/09/2016",1.1221,1.1254,1.1279,1.1219),
PriceBar("23/09/2016",1.1205,1.1226,1.1244,1.1191),
PriceBar("22/09/2016",1.1192,1.1207,1.1258,1.1181),
PriceBar("21/09/2016",1.1148,1.1189,1.12,1.1119),
PriceBar("20/09/2016",1.1176,1.1155,1.1216,1.1144),
PriceBar("19/09/2016",1.116,1.1174,1.1198,1.1146),
PriceBar("16/09/2016",1.1242,1.1155,1.1256,1.1145),
PriceBar("15/09/2016",1.1246,1.1244,1.1286,1.1217),
PriceBar("14/09/2016",1.1215,1.125,1.1274,1.1207),
PriceBar("13/09/2016",1.1233,1.122,1.1262,1.12),
PriceBar("12/09/2016",1.123,1.1234,1.1269,1.1209),
PriceBar("09/09/2016",1.1259,1.1233,1.1288,1.1197),
PriceBar("08/09/2016",1.1237,1.1261,1.1329,1.1231),
PriceBar("07/09/2016",1.1253,1.1239,1.1271,1.1226),
PriceBar("06/09/2016",1.1144,1.1256,1.1266,1.1137),
PriceBar("05/09/2016",1.1149,1.1147,1.1185,1.1137),
PriceBar("02/09/2016",1.1194,1.1156,1.1254,1.1148),
PriceBar("01/09/2016",1.1155,1.1198,1.1207,1.1126),
PriceBar("31/08/2016",1.1141,1.1158,1.1167,1.1121),
PriceBar("30/08/2016",1.1187,1.1143,1.1198,1.1128),
PriceBar("29/08/2016",1.1191,1.1189,1.1208,1.1156),
PriceBar("26/08/2016",1.1281,1.1198,1.1343,1.1177),
PriceBar("25/08/2016",1.1262,1.1283,1.1301,1.1254),
PriceBar("24/08/2016",1.1303,1.1263,1.1316,1.1242),
PriceBar("23/08/2016",1.1318,1.1306,1.1357,1.1299),
PriceBar("22/08/2016",1.1302,1.1319,1.1334,1.1269),
PriceBar("19/08/2016",1.135,1.1326,1.1363,1.1302),
PriceBar("18/08/2016",1.1291,1.1354,1.1367,1.1281), 
PriceBar("17/08/2016",1.1276,1.1288,1.1318,1.1239),
PriceBar("16/08/2016",1.118,1.1278,1.1324,1.1173),
PriceBar("15/08/2016",1.1161,1.1184,1.1203,1.1152),
PriceBar("12/08/2016",1.1136,1.1161,1.1224,1.1127),
PriceBar("11/08/2016",1.1173,1.1137,1.1194,1.1131),
PriceBar("10/08/2016",1.1115,1.1177,1.1193,1.11),
PriceBar("09/08/2016",1.1087,1.1119,1.1124,1.1067),
PriceBar("08/08/2016",1.1085,1.1093,1.1107,1.107),
PriceBar("05/08/2016",1.1127,1.1085,1.1162,1.1043),
PriceBar("04/08/2016",1.1147,1.113,1.1158,1.1112),
PriceBar("03/08/2016",1.1222,1.1149,1.1233,1.1137),
PriceBar("02/08/2016",1.116,1.1227,1.1236,1.1153),
PriceBar("01/08/2016",1.1173,1.1162,1.1186,1.1153),
PriceBar("29/07/2016",1.1075,1.1174,1.12,1.1067),
PriceBar("28/07/2016",1.1056,1.1076,1.1119,1.1047),
PriceBar("27/07/2016",1.0982,1.1058,1.1067,1.0959),
PriceBar("26/07/2016",1.0995,1.0987,1.1031,1.0976),
PriceBar("25/07/2016",1.0968,1.0994,1.1002,1.095),
PriceBar("22/07/2016",1.1027,1.0976,1.1042,1.0951),
PriceBar("21/07/2016",1.1011,1.1025,1.106,1.0979),
PriceBar("20/07/2016",1.1018,1.1015,1.1032,1.0979),
PriceBar("19/07/2016",1.1072,1.1022,1.1086,1.0998),
PriceBar("18/07/2016",1.104,1.1074,1.1086,1.1035),
PriceBar("15/07/2016",1.1116,1.1036,1.115,1.1021),
PriceBar("14/07/2016",1.1087,1.112,1.1166,1.1083),
PriceBar("13/07/2016",1.1059,1.109,1.1121,1.1041),
PriceBar("12/07/2016",1.1056,1.1059,1.1127,1.1048),
PriceBar("11/07/2016",1.105,1.1058,1.1076,1.1014),
PriceBar("08/07/2016",1.106,1.1055,1.1115,1.0999),
PriceBar("07/07/2016",1.1097,1.1063,1.1113,1.1049),
PriceBar("06/07/2016",1.1074,1.1099,1.1112,1.1069),
PriceBar("05/07/2016",1.1153,1.1076,1.1184,1.1058),
PriceBar("04/07/2016",1.114,1.1156,1.1166,1.1095),
PriceBar("01/07/2016",1.1103,1.1136,1.1169,1.1069) ] 

print(data_set[3])

#PriceBar.reset_id()
small_set = [ PriceBar("28/09/2016",1.1216,1.1212,1.1237,1.14),
              PriceBar("28/09/2016",1.1216,1.1212,1.1237,1.13),
              PriceBar("28/09/2016",1.1216,1.1212,1.1237,1.12),
              PriceBar("28/09/2016",1.1216,1.1212,1.1237,1.11),
              PriceBar("28/09/2016",1.1216,1.1212,1.1237,1.13),
              PriceBar("28/09/2016",1.1216,1.1212,1.1237,1.12),
              PriceBar("28/09/2016",1.1216,1.1212,1.1237,1.14) ]


my_set = dataset(data_set)
my_set.calculate_trues()

i = 1
while 1:
    res1 = my_set.get_demand_tdpoints(i)
    res2 = my_set.get_supply_tdpoints(i)
    print("level %d demand size is %d" % (i, len(res1)))
    print("level %d supply size is %d" % (i, len(res2)))
    i += 1
    if (0 == len(res1) and 0 == len(res2)):
        break



print("size of data set is %d" % len(data_set))
