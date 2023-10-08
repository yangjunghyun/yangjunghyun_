import pandas as pd

class data_preprocessing:
    def smart_card_preprocessing(exdata): # 스마트카드 데이터 전처리
        exdata = exdata[exdata['GETOFF_BUS_STTN_ID']!='~      '] # 하차 태그 없는 데이터 제거
        exdata['GETON_TM'] = exdata['GETON_TM'].apply(lambda x: str(x).zfill(6)) # GETON_TM 컬럼 날짜형식으로 변환하기 위해 자릿수 맞춰주기
        
        # datetime 형식으로 변환 및 새로운 column 생성
        exdata['GETON_DATETIME'] = pd.to_datetime(exdata['GETON_YMD'].astype(str) + exdata['GETON_TM'].astype(str), format = '%Y%m%d%H%M%S')
        exdata['GETOFF_DATETIME'] = pd.to_datetime(exdata['GETOFF_YMD'].astype(str) + exdata['GETOFF_TM'].astype(str), format = '%Y%m%d%H%M%S', errors = 'coerce')
        exdata['WEEKDAY'] = exdata['GETON_DATETIME'].dt.weekday
        exdata['DAY'] = exdata['GETON_DATETIME'].dt.day
        
        # 평일만 추출
        weekday_values = [0, 1, 2, 3, 4]
        exdata = exdata[exdata['WEEKDAY'].isin(weekday_values)]
        
        # 여러명이 탄 경우 제거
        exdata = exdata[exdata['YSR_CNT']==1]
        
        # 사용한 행 제거
        exdata.drop(labels = ['GETON_YMD','GETON_TM','GETOFF_YMD','GETOFF_TM'], axis = 1, inplace = True)

        # 필요없는 행 제거
        exdata.drop(labels = ['SERIAL_NO', 'TRANSACTION_ID', 'BUS_CO_ID', 'BUS_CAR_ID', 'DRVR_ID','DRVN_START_YMD','DRVN_START_TM','GETON_CALC_YMD', 'GETOFF_CALC_YMD', 'ETL_TYPE', 'ETL_DATE'], axis = 1, inplace = True)
        
        return exdata
    
class transf_data_preprocessing:
    def transf_2_preprocessing(exdata):
        # TRANSF_CNT가 3인 CARD_NO에 해당하는 행을 제거 (환승횟수 3인 경우 대부분 타지역에서 오는 경우이므로 제거)
        exdata = exdata[~exdata['CARD_NO'].isin(exdata[exdata['TRANSF_CNT']==3]['CARD_NO'])]
        
        ##### 환승횟수 2회 #####
        dataframes_by_card_no = {}
        
        for idx, card_no in enumerate(set(exdata[exdata['TRANSF_CNT'] == 2]['CARD_NO'].unique()), 1):
            filtered_df = exdata[exdata['CARD_NO'] == card_no].sort_values('GETON_DATETIME')
            dataframes_by_card_no[idx] = filtered_df
        
        combined_dataframe = pd.concat(dataframes_by_card_no.values(), ignore_index = True).sort_values(by = ['CARD_NO', 'GETON_DATETIME'])
        
        # 환승횟수가 2인 경우 unique한 CARD_NO 당 최소 3개(0,1,2)가 존재해야하므로
        exdata_is_2 = combined_dataframe[combined_dataframe['CARD_NO'].map(combined_dataframe['CARD_NO'].value_counts()) == 3]
        return exdata_is_2
    
    def transf_2_merge(exdata, getrouteinfoall_df, bus_sttn_df):
        rows = []
        unique_card_nos = exdata['CARD_NO'].unique()
        for card_no in unique_card_nos:
            card_data = exdata[exdata['CARD_NO'] == card_no]
            
            # 각 CARD_NO에 대해 두 개의 분리된 행을 생성
            row_data = {
                'CARD_NO': card_no,
                'TR_MEANS_TYPE_1': card_data['TR_MEANS_TYPE'].values[0],
                'TRANSF_CNT': card_data['TRANSF_CNT'].values[0],
                'BUS_ROUTE_ID_1': card_data['BUS_ROUTE_ID'].values[0],
                'GETON_BUS_STTN_ID_1': card_data['GETON_BUS_STTN_ID'].values[0],
                'GETON_PAY_1': card_data['GETON_PAY'].values[0],
                'GETON_DATETIME_1': card_data['GETON_DATETIME'].values[0],
                'GETOFF_BUS_STTN_ID_1': card_data['GETOFF_BUS_STTN_ID'].values[0],
                'GETOFF_PAY_1': card_data['GETOFF_PAY'].values[0],
                'GETOFF_DATETIME_1': card_data['GETOFF_DATETIME'].values[0],
                'TR_MEANS_TYPE_2': card_data['TR_MEANS_TYPE'].values[1],
                'BUS_ROUTE_ID_2': card_data['BUS_ROUTE_ID'].values[1],
                'GETON_BUS_STTN_ID_2': card_data['GETON_BUS_STTN_ID'].values[1],
                'GETON_PAY_2': card_data['GETON_PAY'].values[1],
                'GETON_DATETIME_2': card_data['GETON_DATETIME'].values[1],
                'GETOFF_BUS_STTN_ID_2': card_data['GETOFF_BUS_STTN_ID'].values[1],
                'GETOFF_PAY_2': card_data['GETOFF_PAY'].values[1],
                'GETOFF_DATETIME_2': card_data['GETOFF_DATETIME'].values[1],
                'TR_MEANS_TYPE_3': card_data['TR_MEANS_TYPE'].values[2],
                'BUS_ROUTE_ID_3': card_data['BUS_ROUTE_ID'].values[2],
                'GETON_BUS_STTN_ID_3': card_data['GETON_BUS_STTN_ID'].values[2],
                'GETON_PAY_3': card_data['GETON_PAY'].values[2],
                'GETON_DATETIME_3': card_data['GETON_DATETIME'].values[2],
                'GETOFF_BUS_STTN_ID_3': card_data['GETOFF_BUS_STTN_ID'].values[2],
                'GETOFF_PAY_3': card_data['GETOFF_PAY'].values[2],
                'GETOFF_DATETIME_3': card_data['GETOFF_DATETIME'].values[2],
            }
            rows.append(row_data)
        
        exdata = pd.DataFrame(rows)
    
        exdata = exdata.merge(getrouteinfoall_df, left_on = 'BUS_ROUTE_ID_1', right_on = 'ROUTE_CD') # merge
        exdata = exdata.merge(getrouteinfoall_df, left_on = 'BUS_ROUTE_ID_2', right_on = 'ROUTE_CD') # merge
        exdata = exdata.merge(getrouteinfoall_df, left_on = 'BUS_ROUTE_ID_3', right_on = 'ROUTE_CD') # merge
        exdata.drop(labels = ['BUS_ROUTE_ID_1','BUS_ROUTE_ID_2','BUS_ROUTE_ID_3','ROUTE_CD_x','ROUTE_CD_y','ROUTE_CD'], axis = 1, inplace = True) # 사용한 행 제거
        exdata.rename(columns = {'ROUTE_NO_x' : 'ROUTE_NO_1', 'ROUTE_NO_y' : 'ROUTE_NO_2','ROUTE_NO' : 'ROUTE_NO_3'}, inplace = True) # 컬럼명 변경
        exdata = exdata[['CARD_NO', 'TR_MEANS_TYPE_1','ROUTE_NO_1',  'TRANSF_CNT', 'GETON_BUS_STTN_ID_1','GETON_PAY_1', 'GETON_DATETIME_1', 'GETOFF_BUS_STTN_ID_1','GETOFF_PAY_1', 'GETOFF_DATETIME_1', 
                                        'TR_MEANS_TYPE_2','ROUTE_NO_2','GETON_BUS_STTN_ID_2', 'GETON_PAY_2', 'GETON_DATETIME_2','GETOFF_BUS_STTN_ID_2', 'GETOFF_PAY_2', 'GETOFF_DATETIME_2',
                                        'TR_MEANS_TYPE_3','ROUTE_NO_3','GETON_BUS_STTN_ID_3', 'GETON_PAY_3', 'GETON_DATETIME_3','GETOFF_BUS_STTN_ID_3', 'GETOFF_PAY_3', 'GETOFF_DATETIME_3']]
    
        # int형으로 변환
        exdata['GETOFF_BUS_STTN_ID_1'] = exdata['GETOFF_BUS_STTN_ID_1'].astype(int)
        exdata['GETOFF_BUS_STTN_ID_2'] = exdata['GETOFF_BUS_STTN_ID_2'].astype(int)
        exdata['GETOFF_BUS_STTN_ID_3'] = exdata['GETOFF_BUS_STTN_ID_3'].astype(int)
        
        # GETON/GETOFF_1
        exdata = exdata.merge(bus_sttn_df, left_on = 'GETON_BUS_STTN_ID_1', right_on = 'bus_sttn_id')
        exdata = exdata.merge(bus_sttn_df, left_on = 'GETOFF_BUS_STTN_ID_1', right_on = 'bus_sttn_id')
        exdata.drop(labels = ['bus_sttn_id_x', 'bus_sttn_id_y'], axis = 1, inplace = True)
        exdata.rename(columns = {'posx_x' : 'GETON_BUS_X_1', 'posy_x' : 'GETON_BUS_Y_1', 'posx_y' : 'GETOFF_BUS_X_1', 'posy_y' : 'GETOFF_BUS_Y_1'}, inplace = True) # 컬럼명 변경
        exdata = exdata[['CARD_NO', 'TR_MEANS_TYPE_1', 'ROUTE_NO_1', 'TRANSF_CNT','GETON_BUS_STTN_ID_1', 'GETON_PAY_1', 'GETON_DATETIME_1','GETON_BUS_X_1', 'GETON_BUS_Y_1','GETOFF_BUS_STTN_ID_1', 'GETOFF_PAY_1', 'GETOFF_DATETIME_1','GETOFF_BUS_X_1', 'GETOFF_BUS_Y_1',
                                                'TR_MEANS_TYPE_2', 'ROUTE_NO_2', 'GETON_BUS_STTN_ID_2', 'GETON_PAY_2','GETON_DATETIME_2', 'GETOFF_BUS_STTN_ID_2', 'GETOFF_PAY_2','GETOFF_DATETIME_2',
                                                'TR_MEANS_TYPE_3', 'ROUTE_NO_3', 'GETON_BUS_STTN_ID_3', 'GETON_PAY_3','GETON_DATETIME_3', 'GETOFF_BUS_STTN_ID_3', 'GETOFF_PAY_3','GETOFF_DATETIME_3']]

        # GETON/GETOFF_2
        exdata = exdata.merge(bus_sttn_df, left_on = 'GETON_BUS_STTN_ID_2', right_on = 'bus_sttn_id')
        exdata = exdata.merge(bus_sttn_df, left_on = 'GETOFF_BUS_STTN_ID_2', right_on = 'bus_sttn_id')
        exdata.drop(labels = ['bus_sttn_id_x', 'bus_sttn_id_y'], axis = 1, inplace = True)
        exdata.rename(columns = {'posx_x' : 'GETON_BUS_X_2', 'posy_x' : 'GETON_BUS_Y_2', 'posx_y' : 'GETOFF_BUS_X_2', 'posy_y' : 'GETOFF_BUS_Y_2'}, inplace = True) # 컬럼명 변경
        exdata = exdata[['CARD_NO', 'TR_MEANS_TYPE_1', 'ROUTE_NO_1', 'TRANSF_CNT','GETON_BUS_STTN_ID_1', 'GETON_PAY_1', 'GETON_DATETIME_1','GETON_BUS_X_1', 'GETON_BUS_Y_1','GETOFF_BUS_STTN_ID_1', 'GETOFF_PAY_1', 'GETOFF_DATETIME_1','GETOFF_BUS_X_1', 'GETOFF_BUS_Y_1',
                                                'TR_MEANS_TYPE_2', 'ROUTE_NO_2', 'GETON_BUS_STTN_ID_2', 'GETON_PAY_2','GETON_DATETIME_2','GETON_BUS_X_2', 'GETON_BUS_Y_2', 'GETOFF_BUS_STTN_ID_2', 'GETOFF_PAY_2','GETOFF_DATETIME_2','GETOFF_BUS_X_2','GETOFF_BUS_Y_2',
                                                'TR_MEANS_TYPE_3', 'ROUTE_NO_3', 'GETON_BUS_STTN_ID_3', 'GETON_PAY_3','GETON_DATETIME_3', 'GETOFF_BUS_STTN_ID_3', 'GETOFF_PAY_3','GETOFF_DATETIME_3']]
        # GETON/GETOFF_3
        exdata = exdata.merge(bus_sttn_df, left_on = 'GETON_BUS_STTN_ID_3', right_on = 'bus_sttn_id')
        exdata = exdata.merge(bus_sttn_df, left_on = 'GETOFF_BUS_STTN_ID_3', right_on = 'bus_sttn_id')
        exdata.drop(labels = ['bus_sttn_id_x', 'bus_sttn_id_y'], axis = 1, inplace = True)
        exdata.rename(columns = {'posx_x' : 'GETON_BUS_X_3', 'posy_x' : 'GETON_BUS_Y_3', 'posx_y' : 'GETOFF_BUS_X_3', 'posy_y' : 'GETOFF_BUS_Y_3'}, inplace = True) # 컬럼명 변경
        exdata = exdata[['CARD_NO', 'TR_MEANS_TYPE_1', 'ROUTE_NO_1', 'TRANSF_CNT','GETON_BUS_STTN_ID_1', 'GETON_PAY_1', 'GETON_DATETIME_1','GETON_BUS_X_1', 'GETON_BUS_Y_1','GETOFF_BUS_STTN_ID_1', 'GETOFF_PAY_1', 'GETOFF_DATETIME_1','GETOFF_BUS_X_1', 'GETOFF_BUS_Y_1',
                                                'TR_MEANS_TYPE_2', 'ROUTE_NO_2', 'GETON_BUS_STTN_ID_2', 'GETON_PAY_2','GETON_DATETIME_2','GETON_BUS_X_2', 'GETON_BUS_Y_2', 'GETOFF_BUS_STTN_ID_2', 'GETOFF_PAY_2','GETOFF_DATETIME_2','GETOFF_BUS_X_2','GETOFF_BUS_Y_2',
                                                'TR_MEANS_TYPE_3', 'ROUTE_NO_3', 'GETON_BUS_STTN_ID_3', 'GETON_PAY_3','GETON_DATETIME_3', 'GETOFF_BUS_STTN_ID_3', 'GETOFF_PAY_3','GETOFF_DATETIME_3','GETOFF_BUS_X_3','GETOFF_BUS_Y_3']]
        
        return exdata
    
    
    def transf_1_preprocessing(exdata): # 환승 횟수 1번인 데이터 전처리
        # TRANSF_CNT가 2인 CARD_NO를 가져옴
        card_nos_to_remove = exdata[exdata['TRANSF_CNT'] == 2]['CARD_NO']
        # 지정된 CARD_NO에 해당하는 행을 제거
        exdata = exdata[~exdata['CARD_NO'].isin(card_nos_to_remove)]
        
        ##### 환승횟수 1회 #####
        dataframes_by_card_no = {}

        # TRANSF_CNT가 1인 경우의 CARD_NO 값들을 가져옴
        unique_card_nos = set(exdata[exdata['TRANSF_CNT'] == 1]['CARD_NO'].unique())

        # 고유한 CARD_NO 값들을 순회하며 데이터프레임 생성
        for idx, card_no in enumerate(unique_card_nos, 1):
            # 현재 CARD_NO에 해당하는 데이터를 원본 데이터프레임에서 필터링하고, GETON_DATETIME으로 정렬
            filtered_df = exdata[exdata['CARD_NO'] == card_no].sort_values('GETON_DATETIME')
            
            # 현재 필터링된 데이터프레임을 딕셔너리에 저장
            dataframes_by_card_no[idx] = filtered_df

        # 딕셔너리의 모든 데이터프레임을 합쳐서 하나의 데이터프레임으로 만듦
        combined_dataframe = pd.concat(dataframes_by_card_no.values(), ignore_index=True)
        
        # CARD_NO, GETON_DATETIME으로 정렬    
        combined_dataframe = combined_dataframe.sort_values(by = ['CARD_NO', 'GETON_DATETIME'])
        
        # 환승횟수가 1인 경우 unique한 CARD_NO 당 최소 2개(0,1)가 존재해야하므로
        exdata_is_1 = combined_dataframe[combined_dataframe['CARD_NO'].map(combined_dataframe['CARD_NO'].value_counts()) == 2]
#        exdata_is_not_1 = combined_dataframe[combined_dataframe['CARD_NO'].map(combined_dataframe['CARD_NO'].value_counts()) != 2]
        
        return exdata_is_1
    
    def transf_1_merge(exdata, getrouteinfoall_df, bus_sttn_df): # 환승 횟수 1번인 데이터 merge
        rows = []

        unique_card_nos = exdata['CARD_NO'].unique() # 'CARD_NO' 열에서 유니크한 카드 번호를 추출
        for card_no in unique_card_nos: # 각 카드 번호별로 반복
            card_data = exdata[exdata['CARD_NO'] == card_no] # 현재 카드 번호에 해당하는 데이터를 추출

            # 각 CARD_NO에 대해 두 개의 분리된 행을 생성
            row_data = {
                'CARD_NO': card_no,
                'TR_MEANS_TYPE_1': card_data['TR_MEANS_TYPE'].values[0],
                'TRANSF_CNT': card_data['TRANSF_CNT'].values[0],
                'BUS_ROUTE_ID_1': card_data['BUS_ROUTE_ID'].values[0],
                'GETON_BUS_STTN_ID_1': card_data['GETON_BUS_STTN_ID'].values[0],
                'GETON_PAY_1': card_data['GETON_PAY'].values[0],
                'GETON_DATETIME_1': card_data['GETON_DATETIME'].values[0],
                'GETOFF_BUS_STTN_ID_1': card_data['GETOFF_BUS_STTN_ID'].values[0],
                'GETOFF_PAY_1': card_data['GETOFF_PAY'].values[0],
                'GETOFF_DATETIME_1': card_data['GETOFF_DATETIME'].values[0],
                'TR_MEANS_TYPE_2': card_data['TR_MEANS_TYPE'].values[1],
                'BUS_ROUTE_ID_2': card_data['BUS_ROUTE_ID'].values[1],
                'GETON_BUS_STTN_ID_2': card_data['GETON_BUS_STTN_ID'].values[1],
                'GETON_PAY_2': card_data['GETON_PAY'].values[1],
                'GETON_DATETIME_2': card_data['GETON_DATETIME'].values[1],
                'GETOFF_BUS_STTN_ID_2': card_data['GETOFF_BUS_STTN_ID'].values[1],
                'GETOFF_PAY_2': card_data['GETOFF_PAY'].values[1],
                'GETOFF_DATETIME_2': card_data['GETOFF_DATETIME'].values[1],
            }
            rows.append(row_data)

        exdata = pd.DataFrame(rows)
        
        exdata = exdata.merge(getrouteinfoall_df, left_on = 'BUS_ROUTE_ID_1', right_on = 'ROUTE_CD')
        exdata = exdata.merge(getrouteinfoall_df, left_on = 'BUS_ROUTE_ID_2', right_on = 'ROUTE_CD')
        exdata.drop(labels = ['BUS_ROUTE_ID_1','BUS_ROUTE_ID_2','ROUTE_CD_x','ROUTE_CD_y'], axis = 1, inplace = True) # 사용한 행 제거
        exdata.rename(columns = {'ROUTE_NO_x' : 'ROUTE_NO_1', 'ROUTE_NO_y' : 'ROUTE_NO_2'}, inplace = True) # 컬럼명 변경
        exdata = exdata[['CARD_NO', 'TR_MEANS_TYPE_1','ROUTE_NO_1',  'TRANSF_CNT', 'GETON_BUS_STTN_ID_1','GETON_PAY_1', 'GETON_DATETIME_1', 'GETOFF_BUS_STTN_ID_1','GETOFF_PAY_1', 'GETOFF_DATETIME_1', 
                                        'TR_MEANS_TYPE_2','ROUTE_NO_2','GETON_BUS_STTN_ID_2', 'GETON_PAY_2', 'GETON_DATETIME_2','GETOFF_BUS_STTN_ID_2', 'GETOFF_PAY_2', 'GETOFF_DATETIME_2']]

        # int형으로 변환
        exdata['GETOFF_BUS_STTN_ID_1'] = exdata['GETOFF_BUS_STTN_ID_1'].astype(int)
        exdata['GETOFF_BUS_STTN_ID_2'] = exdata['GETOFF_BUS_STTN_ID_2'].astype(int)
        
        # GETON/GETOFF_1
        exdata = exdata.merge(bus_sttn_df, left_on = 'GETON_BUS_STTN_ID_1', right_on = 'bus_sttn_id')
        exdata = exdata.merge(bus_sttn_df, left_on = 'GETOFF_BUS_STTN_ID_1', right_on = 'bus_sttn_id')
        exdata.drop(labels = ['bus_sttn_id_x', 'bus_sttn_id_y'], axis = 1, inplace = True)
        exdata.rename(columns = {'posx_x' : 'GETON_BUS_X_1', 'posy_x' : 'GETON_BUS_Y_1', 'posx_y' : 'GETOFF_BUS_X_1', 'posy_y' : 'GETOFF_BUS_Y_1'}, inplace = True) # 컬럼명 변경
        exdata = exdata[['CARD_NO', 'TR_MEANS_TYPE_1', 'ROUTE_NO_1', 'TRANSF_CNT','GETON_BUS_STTN_ID_1', 'GETON_PAY_1', 'GETON_DATETIME_1','GETON_BUS_X_1', 'GETON_BUS_Y_1','GETOFF_BUS_STTN_ID_1', 'GETOFF_PAY_1', 'GETOFF_DATETIME_1','GETOFF_BUS_X_1', 'GETOFF_BUS_Y_1',
                                                'TR_MEANS_TYPE_2', 'ROUTE_NO_2', 'GETON_BUS_STTN_ID_2', 'GETON_PAY_2','GETON_DATETIME_2', 'GETOFF_BUS_STTN_ID_2', 'GETOFF_PAY_2','GETOFF_DATETIME_2']]

        # GETON/GETOFF_2
        exdata = exdata.merge(bus_sttn_df, left_on = 'GETON_BUS_STTN_ID_2', right_on = 'bus_sttn_id')
        exdata = exdata.merge(bus_sttn_df, left_on = 'GETOFF_BUS_STTN_ID_2', right_on = 'bus_sttn_id')
        exdata.drop(labels = ['bus_sttn_id_x', 'bus_sttn_id_y'], axis = 1, inplace = True)
        exdata.rename(columns = {'posx_x' : 'GETON_BUS_X_2', 'posy_x' : 'GETON_BUS_Y_2', 'posx_y' : 'GETOFF_BUS_X_2', 'posy_y' : 'GETOFF_BUS_Y_2'}, inplace = True) # 컬럼명 변경
        exdata = exdata[['CARD_NO', 'TR_MEANS_TYPE_1', 'ROUTE_NO_1', 'TRANSF_CNT','GETON_BUS_STTN_ID_1', 'GETON_PAY_1', 'GETON_DATETIME_1','GETON_BUS_X_1', 'GETON_BUS_Y_1','GETOFF_BUS_STTN_ID_1', 'GETOFF_PAY_1', 'GETOFF_DATETIME_1','GETOFF_BUS_X_1', 'GETOFF_BUS_Y_1',
                                                'TR_MEANS_TYPE_2', 'ROUTE_NO_2', 'GETON_BUS_STTN_ID_2', 'GETON_PAY_2','GETON_DATETIME_2','GETON_BUS_X_2', 'GETON_BUS_Y_2', 'GETOFF_BUS_STTN_ID_2', 'GETOFF_PAY_2','GETOFF_DATETIME_2','GETOFF_BUS_X_2','GETOFF_BUS_Y_2']]

        return exdata
       
    def transf_0_preprocessing(exdata): # 환승 횟수 0번인 데이터 전처리
        # TRANSF_CNT가 1인 CARD_NO를 가져옴
        card_nos_to_remove = exdata[exdata['TRANSF_CNT'] == 1]['CARD_NO']
        # 지정된 CARD_NO에 해당하는 행을 제거
        exdata = exdata[~exdata['CARD_NO'].isin(card_nos_to_remove)]
        
        # 환승횟수가 0이면서 출근시간에 한 번만 이동한 경우
        exdata_is_0 = exdata[exdata['CARD_NO'].map(exdata['CARD_NO'].value_counts()) == 1]
#        exdata_is_not_0 = exdata[exdata['CARD_NO'].map(exdata['CARD_NO'].value_counts()) != 1]

        return exdata_is_0
    
    def transf_0_merge(exdata, getrouteinfoall_df, bus_sttn_df): # 환승 횟수 0번인 데이터 merge
        exdata = exdata.merge(getrouteinfoall_df, left_on = 'BUS_ROUTE_ID', right_on = 'ROUTE_CD')
        exdata.drop(labels = ['BUS_ROUTE_ID','ROUTE_CD'], axis = 1, inplace = True) # 사용한 행 제거
        exdata = exdata[['CARD_NO', 'TR_MEANS_TYPE','ROUTE_NO', 'TRANSF_CNT', 'GETON_BUS_STTN_ID','GETON_PAY', 'GETON_DATETIME', 'GETOFF_BUS_STTN_ID','GETOFF_PAY', 'GETOFF_DATETIME']]

        # int타입으로 변환
        exdata['GETOFF_BUS_STTN_ID'] = exdata['GETOFF_BUS_STTN_ID'].astype(int)

        # GETON/GETOFF 정류장 좌표 merge
        exdata = exdata.merge(bus_sttn_df, left_on = 'GETON_BUS_STTN_ID', right_on = 'bus_sttn_id')
        exdata = exdata.merge(bus_sttn_df, left_on = 'GETOFF_BUS_STTN_ID', right_on = 'bus_sttn_id')
        exdata.drop(labels = ['bus_sttn_id_x', 'bus_sttn_id_y'], axis = 1, inplace = True)
        exdata.rename(columns = {'posx_x' : 'GETON_BUS_X', 'posy_x' : 'GETON_BUS_Y', 'posx_y' : 'GETOFF_BUS_X', 'posy_y' : 'GETOFF_BUS_Y'}, inplace = True) # 컬럼명 변경
        exdata = exdata[['CARD_NO', 'TR_MEANS_TYPE', 'ROUTE_NO', 'TRANSF_CNT','GETON_BUS_STTN_ID', 'GETON_PAY', 'GETON_DATETIME','GETON_BUS_X', 'GETON_BUS_Y','GETOFF_BUS_STTN_ID', 'GETOFF_PAY', 'GETOFF_DATETIME','GETOFF_BUS_X', 'GETOFF_BUS_Y']]

        return exdata    
    
    
    
    