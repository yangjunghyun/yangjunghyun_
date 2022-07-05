###03-30###

data_3.3 <- read.table("All_Data/P060.txt", header = T,sep="\t")
dim(data_3.3) # 30개의 행과 7개의 열
class(data_3.3) # 데이터의 형태를 확인해야함.
sapply(data_3.3, class) # 각각 변수들의 형태 확인.
# numeric : 실수형태
summary(data_3.3)

#변수가 많지 않을 땐 산점도 행렬을 볼 수 있음.
plot(data_3.3)


### 3.4 : 모수 추정
lm(Y~X1+X2+X3+X4+X5+X6,data =data_3.3)
lm(Y~.,data =data_3.3) # . : Y를 제외한 변수 전부 다

