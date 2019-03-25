import re
import csv
import os
from urllib import request


class Spider():

    '''通用的正则表达式定义'''
    common1_pattern= r'>([\s\S]*?)$'

    '''淘宝产品详情正则定义'''
    product_detail_tb_pattern=r'<div class="tb-property tb-property-x">([\s\S]*?)class="tb-sidebar tb-clear"'
    detail_title_tb_pattern=r'<h3 class="tb-main-title"([\s\S]*?)</h3>'
    detail_price_tb_pattern=r'<em class="tb-rmb-num">([\s\S]*?)</em>'
    detail_discount_price_tb_pattern=r'<em id="J_PromoPriceNum" class="tb-rmb-num">([\s\S]*?)</em>'
    detail_commentNum_tb_pattern=r'<strong id="J_RateCounter">([\s\S]*?)</strong>'
    detail_tradeNum_tb_pattern=r'<strong id="J_SellCounter">([\s\S]*?)</strong>'
    detail_stockNum_tb_pattern=r'<span id="J_SpanStock">([\s\S]*?)</span>'
    detail_popularity_tb_pattern=r'<em class="J_FavCount">([\s\S]*?)</em>'
    product_attitudes_tb_pattern=r'<ul class="attributes-list">([\s\S]*?)</ul>'
    product_attitude_tb_pattern=r'>([\s\S]*?)</li>'
    '''天猫产品详情正则定义'''
    product_detail_tm_pattern=r'<div class="tb-property">([\s\S]*?)id="J_FrmBid"'
    detail_newp_tm_pattern=r'<p class="newp"([\s\S]*?)</p>'
    tradeNum_commentNum_tm_pattern=r'<span class="tm-count">([\s\S]*?)</span>'
    price_common_pattern=r'<span class="tm-price">([\s\S]*?)</span>'
    detail_stockNum_tm_pattern=r'id="J_EmStock"([\s\S]*?)</em>'
    detail_popularity_tm_pattern=r'<span id="J_CollectCount">([\s\S]*?)</span>'
    product_attitudes_tm_pattern=r'<ul id="J_AttrUL">([\s\S]*?)</ul>'
    product_attitude_tm_pattern=r'>([\s\S]*?)</li>'

    def __fetcg_content(self,file_path):
        with open(file_path, encoding='utf-8') as f:
            htmls = f.read()
            f.close()
        return htmls

    def __analysis(self, htmls,file_path):
        #根据file_path判断是来自淘宝还是天猫
        params=file_path[0:-4].split('#')
        if params[len(params)-1]=="0":#说明来自于淘宝
            product_detail = re.findall(self.product_detail_tb_pattern, htmls)
            if len(product_detail)==1:
                #价格字段获取
                price=re.findall(self.detail_price_tb_pattern, product_detail[0])
                price="￥"+self.__param_handle(price)
                #促销价格获取
                discount_price=re.findall(self.detail_discount_price_tb_pattern, product_detail[0])
                discount_price="￥"+self.__param_handle(discount_price_detail)
                #累计评价数获取
                commentNum=re.findall(self.detail_commentNum_tb_pattern, product_detail[0])
                commentNum=self.__param_handle(commentNum)
                #交易成功数量
                tradeNum=re.findall(self.detail_tradeNum_tb_pattern, product_detail[0])
                tradeNum=self.__param_handle(tradeNum)
                #库存数量
                stockNum=re.findall(self.detail_stockNum_tb_pattern, product_detail[0])
                stockNum=self.__param_handle(stockNum)
                #收藏人气
                popularity=re.findall(self.detail_popularity_tb_pattern,htmls)
                if len(popularity)==1:
                    popularity=re.findall("\\d+",popularity[0])
                    popularity=self.__param_handle(popularity)
                #获取所有属性列表
                product_attitudes = re.findall(self.product_attitudes_tb_pattern, htmls)
                if len(product_attitudes)==1:
                    product_attitudes = re.findall(self.product_attitude_tb_pattern,product_attitudes[0])
                anchor={'price':price,'discount_price':discount_price,'commentNum':commentNum,'tradeNum':tradeNum,'stockNum':stockNum,'popularity':popularity,'product_attitudes':product_attitudes}
        else:#说明来自于天猫
            #获取newp
            product_detail = re.findall(self.product_detail_tm_pattern, htmls)
            if len(product_detail)==1:
                #获取标题下面的小提示
                newp=re.findall(self.detail_newp_tm_pattern, product_detail[0])
                if len(newp)==1:
                    newp=re.findall(self.common1_pattern, newp[0])
                    newp=self.__param_handle(newp)
                #价格字段获取
                all_price=re.findall(self.price_common_pattern, product_detail[0])
                if len(all_price)==2:
                    #价格获取
                    price="￥"+all_price[0]
                    #促销价格获取
                    discount_price="￥"+all_price[1]
                tradeNum_commentNum=re.findall(self.tradeNum_commentNum_tm_pattern, product_detail[0])
                if len(tradeNum_commentNum)>2:
                    #月销量获取
                    tradeNum=tradeNum_commentNum[0]
                    #累计评价获取
                    commentNum=tradeNum_commentNum[1]
                stockNum=re.findall(self.detail_stockNum_tm_pattern, product_detail[0])
                if len(stockNum)==1:
                    stockNum=re.findall(self.common1_pattern, stockNum[0])
                #库存数量
                stockNum=self.__param_handle(stockNum)
                #收藏人气
                popularity=re.findall(self.detail_popularity_tm_pattern, product_detail[0])
                if len(popularity)==1:
                    popularity=re.findall("\\d+",popularity[0])
                    popularity=self.__param_handle(popularity)
                    print(popularity)
                #获取所有属性列表
                product_attitudes = re.findall(self.product_attitudes_tm_pattern, htmls)
                if len(product_attitudes)==1:
                    product_attitudes = re.findall(self.product_attitude_tm_pattern,product_attitudes[0])     
                anchor={'newp':newp,'price':price,'discount_price':discount_price,'commentNum':commentNum,'tradeNum':tradeNum,'stockNum':stockNum,'popularity':popularity,'product_attitudes':product_attitudes}        
        return anchor
    def __save_to_csv(self,anchors,filename):
        params=filename[0:-4].split('#')
        with open(os.getcwd()+'/result/'+params[0][0:-4]+'.csv','w',encoding='gbk',newline='') as f:
            f_scv = csv.DictWriter(f,self.headers)
            f_scv.writeheader()
            f_scv.writerows(anchors)

    def __list_files(self,dir):#传一个目录
        for parent,dirnames,filenames in os.walk(dir,followlinks=True):
            for filename in filenames:
                file_path = os.path.join(parent, filename)
                htmls = self.__fetcg_content(file_path)
                anchor = self.__analysis(htmls,file_path)
                self.__save_to_csv(anchor,filename)

    def __param_handle(self,param):
        if len(param)==1:
            param=param[0].strip()
        else:
            param=''
        return param

    def go(self):
        self.__list_files(r'D:\zidonghua\detail')

spider = Spider()
spider.go()
