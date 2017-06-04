import fileinput
mode = ""
class indicator:
    totalTime = 0
    count = 0
    def __init__(self, tt, c):
        self.totalTime = tt
        self.count = c
    def increaseCount(self):
        self.count += 1
    def increaseTime(self, increaseTime):
        self.totalTime += float(increaseTime)
    def getCount(self):
        return self.count
    def getTotalTime(self):
        return self.totalTime


asdf = dict()
for line in fileinput.input():
    total = 0
    operations = 0
    items = line.split(':')
    TID = items[1]
    ms = items[5]
    mode = items[3]
    if TID not in asdf:
        asdf[TID] = indicator(total, operations)
    value = asdf[TID]
    value.increaseTime(ms)
    value.increaseCount()

totalaverage = 0
i = 0
for k, v in asdf.iteritems():
    totalaverage += v.getTotalTime()/v.getCount()
    i += 1
    #print 'TID:%s, total GEMM:%s, elapseTime:%s, average:%s'%(k, v.getCount(), v.getTotalTime(), v.getTotalTime()/v.getCount())
print "mode:%s:total_average:%s"%(mode, totalaverage/i)
