import re
import csv
import os
import shutil

from urllib import request


class Spider():

    '''常量定义'''
    #字符串标识产品来自淘宝
    FROM_TAOBAO='item.taobao.com'
    #字符串标识产品来自天猫
    FROM_TIANMAO='detail.tmall.com'

    '''通用的正则表达式定义'''
    common1_pattern= r'">([\s\S]*?)$'

    '''生意参谋正则定义'''
    # 获取20条数据的根正则
    root_pattern = r'<tr class="ant-table-row oui-table-row-tree-node-([\s\S]*?)</tr>'
    # 从基础数据中匹配到商品title和链接的正则
    title_url_pattern = r'<p class="singleGoodsName">([\s\S]*?)</p>'
    # 获取到商品的标题正则
    title_pattern = r'target="_blank">([\s\S]*?)</a>'
    # 获取到商品的超链接的正则
    url_pattern = r'href="([\s\S]*?)"'
    # 获取行业排名和行业排名变动的正则
    rangeChange_pattern = r'<div class="alife-dt-card-common-table-sortable-td alife-dt-card-common-table-cateRankId">([\s\S]*?)</div>'
    # 获取行业排名变动的正则
    changeNum_pattern = r'<div class="alife-dt-card-common-table-sortable-cycleCrc"([\s\S]*?)</span>'
    # 获取商品排名、交易指数、交易增长幅度、支付转化指数数据
    rangeNum_tradeIndex_tradeGrowth_payConverIndex_pattern = r'<span class="alife-dt-card-common-table-sortable-value">([\s\S]*?)</span>'
   
    '''csv文件参数设置'''
    headers = ['title','url','changeNum','rangeNum','tradeIndex','tradeGrowth','payConverIndex']
    tempFile_headers=['fileName','url','rowNum']

    def __init__(self):
        #进行一些目录的初始化操作
        if os.path.exists(os.getcwd()+'/temp'):
            shutil.rmtree(os.getcwd()+'/temp')
        if os.path.exists(os.getcwd()+'/result'):
            shutil.rmtree(os.getcwd()+'/result')
        os.mkdir(os.getcwd()+'/temp')
        os.mkdir(os.getcwd()+'/result')
        
    def __fetcg_content(self,file_path):
        with open(file_path, encoding='utf-8') as f:
            htmls = f.read()
            f.close()
        return htmls

    def __analysis(self, htmls):
        # 解析出20条完整的数据
        datas = re.findall(self.root_pattern, str(htmls))
        # 存放完整的20条数据的信息,包括：商品名称，商品url等信息
        anchors = []
        for data in datas:
            # 获取商品中包含商品title和url的字符串
            title_url = re.findall(self.title_url_pattern, data)
            # title获得
            if len(title_url)==1:
                title = re.findall(self.title_pattern, title_url[0])
                title=self.__param_handle(title)
                # 超链接获得
                url = re.findall(self.url_pattern, title_url[0])
                url=self.__param_handle(url)
            # 获取行业排名变动的字符串
            rangeChange = re.findall(self.rangeChange_pattern, data)
            # 获取行业排名变化值(此处需要作判断，为-和有值时标签不同)
            if len(rangeChange)==1:
                print(rangeChange[0])
                changeNum = re.findall(self.changeNum_pattern, rangeChange[0])
                # 排名变化获得
                if len(changeNum) == 0:  # 说明排名在页面显示为-
                    changeNum = '-'
                else:
                    changeNum = re.findall(self.common1_pattern, changeNum[0])
                    if len(changeNum)==1:
                        changeNum = re.findall(self.common1_pattern, changeNum[0])
                        changeNum=self.__param_handle(changeNum)
            rangeNum_tradeIndex_tradeGrowth_payConverIndex = re.findall(self.rangeNum_tradeIndex_tradeGrowth_payConverIndex_pattern, data)
            if len(rangeNum_tradeIndex_tradeGrowth_payConverIndex)==4:
                # 排名获得
                rangeNum = rangeNum_tradeIndex_tradeGrowth_payConverIndex[0]
                # 交易指数获得
                tradeIndex = rangeNum_tradeIndex_tradeGrowth_payConverIndex[1]
                tradeIndex=tradeIndex.replace(',','')
                # 交易增长幅度获得
                tradeGrowth = re.findall(self.common1_pattern, rangeNum_tradeIndex_tradeGrowth_payConverIndex[2])
                tradeGrowth=self.__param_handle(tradeGrowth)                  
                # 支付转化指数获得
                payConverIndex = rangeNum_tradeIndex_tradeGrowth_payConverIndex[3]
                payConverIndex=payConverIndex.replace(',','')
            # 将商品数据封装到字典中
            anchor = {'title': title, 'url': url, 'changeNum': changeNum, 'rangeNum': rangeNum,
                      'tradeIndex': tradeIndex, 'tradeGrowth': tradeGrowth, 'payConverIndex': payConverIndex}
            # 将商品信息放到商品信息的list中
            anchors.append(anchor)
        return anchors

    def __save_to_csv(self,anchors,file_name,urlsFileCsv):
        with open(os.getcwd()+'/result/'+file_name[0:-4]+'.csv','w',encoding='gbk',errors='ignore',newline='') as f:
            f_scv = csv.DictWriter(f,self.headers)
            f_scv.writeheader()
            f_scv.writerows(anchors)
            i=0
            for anchor in anchors:
                i=i+1
                urlsFileCsv.writerow({'fileName':file_name,'url':anchor['url'],'rowNum':i})

    def __list_files(self,dir,urlsFileCsv):#传一个目录
        for parent,dirnames,filenames in os.walk(dir,followlinks=True):
            for filename in filenames:
                file_path = os.path.join(parent, filename)
                htmls = self.__fetcg_content(file_path)
                anchors = self.__analysis(htmls)
                self.__save_to_csv(anchors,filename,urlsFileCsv)
    def __param_handle(self,param):
        if len(param)==1:
            param=param[0].strip()
        else:
            param=''
        return param

    def go(self):
        #定义一个全局文件,命名方式是存储文件名  商品的url和第几个数据
        urlsFile=open(os.getcwd()+'/temp/'+'fileTemp.csv','w',encoding='gbk',newline='')
        urlsFileCsv= csv.DictWriter(urlsFile,self.tempFile_headers)
        self.__list_files(os.getcwd()+r'\data',urlsFileCsv)

spider = Spider()
spider.go()