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

summary = dict()
asdf = dict()
for line in fileinput.input():
    total = 0
    operations = 0
    items = line.split(':')
    TID = items[1]
    ms = items[5]
    mode = items[3]
    try:
        containerid = items[13]
    except IndexError:
        containerid = "cntid"
    if TID not in asdf:
        asdf[TID] = indicator(total, operations)
    value = asdf[TID]
    value.increaseTime(ms)
    value.increaseCount()
    summary[containerid] = asdf

containertotal = 0
containercount = 0
for k, v in summary.iteritems():
    threadtotal = 0
    threadcount = 0
    for k1, v1 in v.iteritems():
       threadtotal += v1.getTotalTime()/v1.getCount()
       threadcount += 1
    containertotal += threadtotal/threadcount
    containercount += 1
    #print 'TID:%s, total GEMM:%s, elapseTime:%s, average:%s'%(k, v.getCount(), v.getTotalTime(), v.getTotalTime()/v.getCount())
print "mode:%s:total_average:%s"%(mode, containertotal/containercount)
