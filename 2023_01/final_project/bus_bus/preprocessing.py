import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
# import matplotlib.ticker as ticker
from shapely.geometry import Point, LineString
import geopandas as gpd
from folium import utilities
from pyppeteer import launch

class data_preprocessing:
    def merged_data_preprocessing(exdata):
        # 문자열 제거
        exdata['YYYY-MM-DD'] = exdata['YYYY-MM-DD'].str[:10]
        # 'YYYY-MM-DD' 열을 datetime 형식으로 변환
        exdata['YYYY-MM-DD'] = pd.to_datetime(exdata['YYYY-MM-DD'], format='%Y-%m-%d')
        # DAY 변수 추가
        exdata['DAY'] = exdata['YYYY-MM-DD'].dt.day

        exdata_copy = exdata.iloc[:,2:]
        
        return exdata_copy
    
    def merged_df_preprocessing(exdata):
        exdata.dropna(axis = 0, inplace = True) # 결측치 제거
        exdata['일자'] = pd.to_datetime(exdata['일자'], format='%Y-%m-%d') # '일자' 열을 datetime 형식으로 변환
        exdata['DAY'] = exdata['일자'].dt.day # 'DAY' 열 생성
        exdata = exdata[exdata['DAY'].isin([1, 2, 5, 7, 8, 9, 12, 13, 14, 15, 16, 20, 21, 22, 23, 26, 27, 28, 29, 30])] # 평일만 필터링
        exdata['노선'] = exdata['노선'].astype(int) # 노선 float -> int
        exdata.drop(labels = ['DAY','일자'], axis = 1, inplace = True) # 사용한 행 제거
        return exdata
    
    # 자릿수 맞춰주기 ex) 1~2 -> 01~02 이렇게 해야 sort_values()했을 때 순서대로 정렬됨
    def format_section(section):
        parts = section.split('~')
        formatted_parts = [part.zfill(2) for part in parts]
        return f"{formatted_parts[0]}~{formatted_parts[1]}"
        
    
class make_data:
    def bus_average_data(exdata, route_no): # 노선별 평균값 데이터 생성 함수
        day_values = [1, 2, 5, 7, 8, 9, 12, 13, 14, 15, 16, 20, 21, 22, 23, 26, 27, 28, 29, 30]

        average_data = pd.DataFrame()

        for day in day_values:
            bus_data = exdata[(exdata['노선'] == route_no) & (exdata['DAY'] == day)].copy() # 특정 노선과 요일에 해당하는 데이터 필터링
            bus_data.drop(labels=['노선', '정류장', 'DAY'], axis=1, inplace=True)
            bus_data = bus_data.set_index('정류장순번') # 정류장순번을 index로 설정
            average_data = pd.concat([average_data, bus_data])

        average_data = average_data.groupby('정류장순번').mean() # 선택한 요일들에 대한 각 정류장의 평균값 계산
        
        return average_data
    
    def get_bus_stop_tp(getstationbyrouteall_df, ROUTE_BUS_NUMBER, ROUTE_NO):
        # 주어진 버스 노선 번호에 해당하는 버스 노선 코드를 얻은 뒤, 노선 코드에 해당하는 버스 정류장 데이터 추출 <순서대로 진행하지 않으면 버스 정류장 데이터가 중복 됨>
        exdata = getstationbyrouteall_df[getstationbyrouteall_df['ROUTE_CD']==ROUTE_BUS_NUMBER[ROUTE_BUS_NUMBER['ROUTE_NO']==ROUTE_NO]['ROUTE_CD'].values[0]].reset_index(drop=True)
        
        return exdata
    
    def final_data(AVERAGE_DATA, BUS_BUSSTOP_TP):
        exdata = AVERAGE_DATA.merge(BUS_BUSSTOP_TP, left_on = '정류장순번', right_on = 'BUSSTOP_SEQ').set_index('BUSSTOP_SEQ')
        STARTING_POINT = exdata[exdata['BUSSTOP_TP']=='2'].index[0]  # 하행 방향의 첫번째 정류장의 인덱스
        
        # 상행 방향 데이터와 하행 방향 데이터로 분리하여 생성
        exdata_UP = exdata[:STARTING_POINT]
        exdata_UP.drop(labels = ['ROUTE_CD','BUSSTOP_TP'], axis = 1, inplace = True)
        exdata_DOWN = exdata[STARTING_POINT:]
        exdata_DOWN.drop(labels = ['ROUTE_CD','BUSSTOP_TP'], axis = 1, inplace = True)
        
        return exdata_UP, exdata_DOWN # ex) BUS_102_UP, BUS_102_DOWN
    
    #####################BUS_SPEED#####################
    def bus_speed(merged_df, route_num):
        exdata = merged_df[merged_df['노선']==route_num]
        exdata_mean = exdata.groupby('정류장구간').mean()
        exdata_mean.drop(labels = '노선', axis = 1, inplace = True)
        exdata_mean.reset_index(inplace = True)
        exdata_mean['정류장구간_1'] = exdata_mean["정류장구간"].apply(lambda x: x.split('▶')[0].split('-')[1]).astype(int)
        exdata_mean["정류장구간_2"] = exdata_mean["정류장구간"].apply(lambda x: x.split('▶')[1].split('-')[1]).astype(int)
        exdata_mean.drop(labels = ['정류장구간'], axis = 1, inplace = True)
        exdata_mean = exdata_mean[['정류장구간_1', '정류장구간_2','5:00', '6:00', '7:00', '8:00', '9:00', '10:00', '11:00', '12:00', '13:00',
                                '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00']]

        return exdata_mean
    
    def make_coordinate(bus_speed_mean_data, bus_speed_route_data):
        exdata_merge = bus_speed_mean_data.merge(bus_speed_route_data, left_on = '정류장구간_1', right_on = 'BUS_STOP_ID')
        exdata_merge.rename(columns = {'BUSSTOP_SEQ' : 'STATION_1_BUSSTOP_SEQ', 'BUSSTOP_TP' : 'STATION_1_BUSSTOP_TP', 'GPS_LATI' : 'STATION_1_GPS_LATI', 'GPS_LONG' : 'STATION_1_GPS_LONG'}, inplace = True)
        exdata_merge = exdata_merge[['정류장구간_1','STATION_1_BUSSTOP_SEQ','STATION_1_BUSSTOP_TP', 'STATION_1_GPS_LATI','STATION_1_GPS_LONG', 
                                                            '정류장구간_2', '5:00', '6:00', '7:00', '8:00', '9:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', 
                                                            '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00']]
        exdata_merge = exdata_merge.merge(bus_speed_route_data, left_on = '정류장구간_2', right_on = 'BUS_STOP_ID')
        exdata_merge.rename(columns = {'BUSSTOP_SEQ' : 'STATION_2_BUSSTOP_SEQ', 'BUSSTOP_TP' : 'STATION_2_BUSSTOP_TP', 'GPS_LATI' : 'STATION_2_GPS_LATI', 'GPS_LONG' : 'STATION_2_GPS_LONG'}, inplace = True)
        exdata_merge = exdata_merge[['정류장구간_1','STATION_1_BUSSTOP_SEQ','STATION_1_BUSSTOP_TP', 'STATION_1_GPS_LATI','STATION_1_GPS_LONG', 
                                                            '정류장구간_2','STATION_2_BUSSTOP_SEQ','STATION_2_BUSSTOP_TP', 'STATION_2_GPS_LATI','STATION_2_GPS_LONG',
                                                            '5:00', '6:00', '7:00', '8:00', '9:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00']]
        
        bus_speed_mean_coordinate_data = exdata_merge.copy()
        
        # 지오메트리 컬럼 생성
        bus_speed_mean_coordinate_data["STATION_1_GEOMETRY"] = bus_speed_mean_coordinate_data.apply(lambda row: Point(row["STATION_1_GPS_LATI"], row["STATION_1_GPS_LONG"]), axis=1)
        bus_speed_mean_coordinate_data["STATION_2_GEOMETRY"] = bus_speed_mean_coordinate_data.apply(lambda row: Point(row["STATION_2_GPS_LATI"], row["STATION_2_GPS_LONG"]), axis=1)
        bus_speed_mean_coordinate_data.drop(labels = ['STATION_1_GPS_LATI','STATION_1_GPS_LONG','STATION_2_GPS_LATI','STATION_2_GPS_LONG'], axis = 1, inplace = True)
        
        # point를 linestring으로 변환해주기
        bus_speed_mean_coordinate_data["LineString"] = [LineString([row["STATION_1_GEOMETRY"], row["STATION_2_GEOMETRY"]]).wkt for _, row in bus_speed_mean_coordinate_data.iterrows()]
        bus_speed_mean_coordinate_data.drop(labels = ['STATION_1_GEOMETRY','STATION_2_GEOMETRY','정류장구간_1','정류장구간_2'], axis = 1, inplace = True)

        # SECTION 열 생성
        bus_speed_mean_coordinate_data["SECTION"] = bus_speed_mean_coordinate_data["STATION_1_BUSSTOP_SEQ"].astype(str) + "~" + bus_speed_mean_coordinate_data["STATION_2_BUSSTOP_SEQ"].astype(str)
        bus_speed_mean_coordinate_data.drop(labels = ['STATION_1_BUSSTOP_SEQ','STATION_2_BUSSTOP_SEQ'], axis = 1, inplace = True)
        bus_speed_mean_coordinate_data = bus_speed_mean_coordinate_data[['SECTION','LineString','6:00', '7:00', '8:00', '9:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00',
                                                                    '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00','STATION_1_BUSSTOP_TP', 'STATION_2_BUSSTOP_TP']]
        # STATION_1_TP = 1 제거
        bus_speed_mean_coordinate_data = bus_speed_mean_coordinate_data[bus_speed_mean_coordinate_data['STATION_2_BUSSTOP_TP']!='1']
        
        # format_section 적용
        bus_speed_mean_coordinate_data['SECTION'] = bus_speed_mean_coordinate_data['SECTION'].apply(data_preprocessing.format_section)
        bus_speed_mean_coordinate_data.sort_values('SECTION',inplace = True)
        
        # 인덱스 초기화
        bus_speed_mean_coordinate_data = bus_speed_mean_coordinate_data.reset_index(drop = True)
        
        return bus_speed_mean_coordinate_data
    
class draw_heatmap:
    # 히트맵 그리는 함수
    def plot_bus_heatmap(bus_number, direction):
        plt.rc('font', family='malgun gothic')
        plt.figure(figsize=(20, 20))
        
        if direction == 'UP':
            heatmap_data = globals().get(f'BUS_{bus_number}_UP')
        elif direction == 'DOWN':
            heatmap_data = globals().get(f'BUS_{bus_number}_DOWN')
        
        heatmap_data = heatmap_data.iloc[:, :19]  # 좌표 데이터 제거 후 히트맵 표시
        
        sns.heatmap(heatmap_data, annot=True, fmt='.1f', vmin=0, vmax=100)
        plt.title(f'{bus_number}번 {direction} 버스 히트맵')
        plt.xlabel('시간대')
        plt.ylabel('정류장순번')

        #  # 그래프를 이미지 파일로 저장
        # image_path = f'./IMAGE_FILE/{bus_number}_{direction}_heatmap.png'
        # plt.savefig(image_path, bbox_inches='tight')

        plt.show()
        
class bus_speed_function:
    # 만든 지도를 png 파일로 캡쳐해서 저장하는 함수
    async def map_to_png(target, m): # target은 저장할 파일 이름
        html = m.get_root().render()
        browser = await launch(headless=True)

        page = await browser.newPage()
        with utilities.temp_html_filepath(html) as fname:
            await page.goto('file://{path}'.format(path=fname))

        img_data = await page.screenshot({'path': f'{target}.png', 'fullPage': 'true', })
        await browser.close()
        
        # await map_to_png('bus_102_10', m)  : 적용 예시