import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import MultipleLocator

class data_preprocessing:
    def smart_card_preprocessing(exdata): # 스마트카드 데이터 전처리
        exdata = exdata[exdata['GETOFF_BUS_STTN_ID']!='~      '] # 하차 태그 없는 데이터 제거
        exdata['GETON_TM'] = exdata['GETON_TM'].apply(lambda x: str(x).zfill(6)) # GETON_TM 컬럼 날짜형식으로 변환하기 위해 자릿수 맞춰주기
        
        # datetime 형식으로 변환 및 새로운 column 생성
        exdata['GETON_DATETIME'] = pd.to_datetime(exdata['GETON_YMD'].astype(str) + exdata['GETON_TM'].astype(str), format = '%Y%m%d%H%M%S')
        exdata['GETOFF_DATETIME'] = pd.to_datetime(exdata['GETOFF_YMD'].astype(str) + exdata['GETOFF_TM'].astype(str), format = '%Y%m%d%H%M%S', errors = 'coerce')
        exdata['WEEKDAY'] = exdata['GETON_DATETIME'].dt.weekday
        exdata['DAY'] = exdata['GETON_DATETIME'].dt.day
        exdata['GETON_TIME'] = exdata['GETON_DATETIME'].dt.hour
        exdata['GETOFF_TIME'] = exdata['GETOFF_DATETIME'].dt.hour
        
        # 여러명이 탄 경우 제거
        exdata = exdata[exdata['YSR_CNT']==1]
        
        # 지선, 간선 버스만 필터링
        exdata = exdata[exdata['TR_MEANS_TYPE'].isin([676, 675])]
        
        # 평일만 추출
        weekday_values = [0, 1, 2, 3, 4]
        exdata = exdata[exdata['WEEKDAY'].isin(weekday_values)]
        
        # 4/15일 수치 이상 제거
        exdata = exdata[exdata['DAY']!=15]
        
        # 환승한 경우 제거
        transf_counts = [3, 2, 1]

        for count in transf_counts:
            card_nos_to_remove = exdata[exdata['TRANSF_CNT'] == count]['CARD_NO']
            exdata = exdata[~exdata['CARD_NO'].isin(card_nos_to_remove)]
            
        # 도시 노선만 사용하기 위해
        values_to_remove = [30300147, 30300148, 30300141, 30300137, 30300149, 30300103]
        exdata = exdata[~exdata['BUS_ROUTE_ID'].isin(values_to_remove)]

        # 사용한 행 제거
        exdata.drop(labels = ['GETON_YMD','GETON_TM','GETOFF_YMD','GETOFF_TM','WEEKDAY','DAY'], axis = 1, inplace = True)
        # 필요없는 행 제거
        exdata.drop(labels = ['SERIAL_NO', 'DRVN_START_YMD','DRVN_START_TM','DRVR_ID','GETON_CALC_YMD','GETOFF_CALC_YMD','ETL_TYPE','ETL_DATE'], axis = 1, inplace = True)

        return exdata
    
    def station_data_for_graph(exdata,bus_sttn, route_id):
        exdata = exdata[exdata['BUS_ROUTE_ID']==route_id]
        value_counts_df = exdata['GETON_BUS_STTN_ID'].value_counts().reset_index()
        value_counts_df.columns = ['GETON_BUS_STTN_ID', 'count']
        exdata = value_counts_df.merge(bus_sttn, left_on = 'GETON_BUS_STTN_ID', right_on = 'bus_sttn_id')
        return exdata
    
    def station_data_for_graph_getoff(exdata,bus_sttn, route_id):
        exdata = exdata[exdata['BUS_ROUTE_ID']==route_id]
        value_counts_df = exdata['GETOFF_BUS_STTN_ID'].value_counts().reset_index()
        value_counts_df.columns = ['GETOFF_BUS_STTN_ID', 'count']
        exdata = value_counts_df.merge(bus_sttn, left_on = 'GETOFF_BUS_STTN_ID', right_on = 'bus_sttn_id')
        return exdata
    
class draw_graph:
    def time_graph_large(exdata, getrouteinfoall ,time):
        exdata = exdata[exdata['GETON_TIME']==time]
        exdata.drop(labels= ['TRANSACTION_ID', 'TR_MEANS_TYPE', 'TRANSF_CNT','USR_TYPE','YSR_CNT','GETON_PAY','GETOFF_PAY','GETON_TIME'], axis = 1, inplace = True)
        exdata = exdata[['CARD_NO','BUS_ROUTE_ID','BUS_CO_ID','BUS_CAR_ID','GETON_BUS_STTN_ID','GETON_DATETIME','GETOFF_BUS_STTN_ID','GETOFF_DATETIME']]
        
        # getrouteinfoall
        getrouteinfoall_df = getrouteinfoall[['ROUTE_CD','ROUTE_NO']]
        exdata = exdata.merge(getrouteinfoall_df, left_on = 'BUS_ROUTE_ID', right_on = 'ROUTE_CD')
        exdata.drop(labels = ['ROUTE_CD'], axis = 1, inplace = True)
        
        # bus_route_id 별 이용량 계산
        bus_route_counts = exdata.groupby('ROUTE_NO').size()
        
        # 상위 10개 선택
        top_10_routes = bus_route_counts.nlargest(10)
        
        # 그래프 그리기
        plt.figure(figsize=(10, 6))
        top_10_routes.plot(kind='bar', color='mediumseagreen')
        plt.xlabel('ROUTE_NO')
        plt.ylabel('이용량')
        plt.title('상위 10개 버스 노선 별 이용량 그래프')
        plt.xticks(rotation=0)
        plt.grid(True, axis = 'y')
        plt.show()

    def time_graph_small(exdata, getrouteinfoall ,time):
        exdata = exdata[exdata['GETON_TIME']==time]
        exdata.drop(labels= ['TRANSACTION_ID', 'TR_MEANS_TYPE', 'TRANSF_CNT','USR_TYPE','YSR_CNT','GETON_PAY','GETOFF_PAY','GETON_TIME'], axis = 1, inplace = True)
        exdata = exdata[['CARD_NO','BUS_ROUTE_ID','BUS_CO_ID','BUS_CAR_ID','GETON_BUS_STTN_ID','GETON_DATETIME','GETOFF_BUS_STTN_ID','GETOFF_DATETIME']]
        
        # getrouteinfoall
        getrouteinfoall_df = getrouteinfoall[['ROUTE_CD','ROUTE_NO']]
        exdata = exdata.merge(getrouteinfoall_df, left_on = 'BUS_ROUTE_ID', right_on = 'ROUTE_CD')
        exdata.drop(labels = ['ROUTE_CD'], axis = 1, inplace = True)
        
        # bus_route_id 별 이용량 계산
        bus_route_counts = exdata.groupby('ROUTE_NO').size()
        
        # 상위 10개 선택
        top_10_routes = bus_route_counts.nsmallest(10)
        
        # 그래프 그리기
        plt.figure(figsize=(10, 6))
        top_10_routes.plot(kind='bar', color='mediumseagreen')
        plt.xlabel('ROUTE_NO')
        plt.ylabel('이용량')
        plt.title('하위 10개 버스 노선 별 이용량 그래프')
        plt.xticks(rotation=0)
        plt.grid(True, axis = 'y')
        plt.show()

    def time_graph(exdata, getrouteinfoall ,time):
        exdata = exdata[exdata['GETON_TIME']==time]
        exdata.drop(labels= ['TRANSACTION_ID', 'TR_MEANS_TYPE', 'TRANSF_CNT','USR_TYPE','YSR_CNT','GETON_PAY','GETOFF_PAY','GETON_TIME'], axis = 1, inplace = True)
        exdata = exdata[['CARD_NO','BUS_ROUTE_ID','BUS_CO_ID','BUS_CAR_ID','GETON_BUS_STTN_ID','GETON_DATETIME','GETOFF_BUS_STTN_ID','GETOFF_DATETIME']]
        
        # getrouteinfoall
        getrouteinfoall_df = getrouteinfoall[['ROUTE_CD','ROUTE_NO']]
        exdata = exdata.merge(getrouteinfoall_df, left_on = 'BUS_ROUTE_ID', right_on = 'ROUTE_CD')
        exdata.drop(labels = ['ROUTE_CD'], axis = 1, inplace = True)
        
        # bus_route_id 별 이용량 계산
        bus_route_counts = exdata.groupby('ROUTE_NO').size()
        
        # 상위 10개 선택
        top_10_routes = bus_route_counts.nlargest(10)
        
        # 버스번호에 따른 색상 매핑
        colors = {'102': 'red', '311': 'orange', '201': 'yellow', '301': 'green', '105': 'blue','106': 'purple', '703': 'pink', 
                '314': 'lightcoral', '103': 'sandybrown', '605': 'beige', '704' : 'palegreen','603':'lightskyblue','705':'mediumslateblue'}
        
        plt.figure(figsize=(10, 6))
        top_10_routes.plot(kind='bar',color=[colors.get(route, 'mediumseagreen') for route in top_10_routes.index])
        plt.xlabel('ROUTE_NO')
        plt.ylabel('이용량')
        plt.title('상위 10개 버스 노선 별 이용량 그래프')
        plt.xticks(rotation=0)
        plt.grid(True, axis = 'y')
        plt.show()
    
    def time_count_geton(exdata):
        # GETON_TIME별 이용량 계산
        geton_time_counts = exdata['GETON_TIME'].value_counts().sort_index()

        plt.figure(figsize=(10, 6))
        plt.bar(geton_time_counts.index, geton_time_counts.values, color='skyblue')
        plt.xlabel('GETON_TIME')
        plt.ylabel('이용량')
        plt.title('승차 시간대별 이용량 그래프')
        plt.gca().xaxis.set_major_locator(MultipleLocator(base=1))
        plt.xticks(rotation=0)
        plt.grid(True, axis = 'y')
        plt.show()
        
    def time_count_getoff(exdata):
        getoff_time_counts = exdata['GETOFF_TIME'].value_counts().sort_index()

        plt.figure(figsize=(10, 6))
        plt.bar(getoff_time_counts.index, getoff_time_counts.values, color='skyblue')
        plt.xlabel('GETOFF_TIME')
        plt.ylabel('이용량')
        plt.title('하차 시간대별 이용량 그래프')
        plt.gca().xaxis.set_major_locator(MultipleLocator(base=1))
        plt.xticks(rotation=0)
        plt.grid(True, axis = 'y')
        plt.show()
