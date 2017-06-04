import fileinput

asdf = dict()

for line in fileinput.input():
    items = line.split('-')
    exec_num = items[4]
    matrix_size = '*'.join([items[8], items[10], items[12]])
    block_size = items[6]

    key = (matrix_size, block_size, exec_num)
    zxcv = asdf.setdefault(key, dict())

    version = items[0].split('/')[1]
    mode = items[2]
    subkey = '_'.join([version, mode])
    zxcv[subkey] = items[19].split(':')[2].split(',')[0]
    gemmFunctionTime = items[19].split(':')[-1].rstrip()
    subkey2 = subkey + '_gemm'
    zxcv[subkey2] = gemmFunctionTime
    #print key, subkey, zxcv, '>', items
print 'Matrix Size,', 'Block Size,', 'Executor Num,', 'DAAL CPU Only(s),', 'Vanilla OpenBLAS(s),', 'DAAL gemm(ms),', 'Vanilla gemm(ms)'
for k, v in asdf.iteritems():
    x1 = v.get('daal_0') or ''
    x2 = v.get('vanilla_0') or ''
    x3 = v.get('daal_0_gemm') or ''
    x4 = v.get('vanilla_0_gemm') or ''
    print ', '.join([k[0], k[1], k[2], x1, x2, x3, x4])
