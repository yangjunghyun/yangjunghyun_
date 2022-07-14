########### 0502 ###########
data_3.3 <- read.table("./All_Data/P060.txt",header = T, sep = "\t")
res_lm <- lm(Y~X1+X3, data = data_3.3)
res_lm


### 회귀진단 그래프들
layout(matrix(1:4, nrow = 2, byrow=T))
plot(res_lm)
layout(1)

# 1. 표준화잔차의 정규확률플롯
plot(res_lm,2)

# 2. 표준화잔차 대 각 예측 변수들의 산점도
plot(res_lm, 3)

# 3. 표준화잔차 대 적합값의 플롯
plot(res_lm,1)

# 4. 표준화잔차 대 인덱스 플롯
plot(res_lm,4)


## 표 2.4
data_2.4 <- read.table("./All_Data/P029b.txt",header = T, sep = "\t")
m <- matrix(1:4, nrow = 2, byrow=T)
layout(m)
plot(Y1~X1, data = data_2.4, pch = 19); abline(3,0.5)
plot(Y1~X2, data = data_2.4, pch = 19); abline(3,0.5)
plot(Y1~X3, data = data_2.4, pch = 19); abline(3,0.5)
plot(Y1~X4, data = data_2.4, pch = 19); abline(3,0.5)

#a
res_lm <- lm(Y1~X1, data = data_2.4)
res_lm

layout(matrix(1:4, nrow = 2, byrow=T))
plot(res_lm)
layout(1)

### 4.8 지레점, 영향력, 특이값
# 사례 : 뉴욕 강 데이터
data_1.9 <- read.table("./All_Data/P010.txt",header = T, sep = "\t")
head(data_1.9)

plot(data_1.9[-1],pch=19) #첫번째 컬럼은 강이름 변수이므로 뺴줌

res_1 <- lm(Nitrogen~., data=data_1.9[-1]) #전체 데이터
res_2 <- lm(Nitrogen~., data=data_1.9[-4,-1]) # 4번째 행을 뻄
res_3 <- lm(Nitrogen~., data=data_1.9[-5,-1]) # 5번째 행을 뺌

# 회귀계수
data.frame(all = coef(res_1),
           rm4 = coef(res_2),
           rm5 = coef(res_3))

# p-value
data.frame(all = coef(summary(res_1))[,4],
           rm4 = coef(summary(res_2))[,4],
           rm5 = coef(summary(res_3))[,4])

## 단순선형회귀모형
res <- lm(Nitrogen~ComIndl,data = data_1.9)

#그림[4.5]
plot(Nitrogen~ComIndl,data = data_1.9, pch = 19)
abline(res)

# leverage values(지레값)
p_ii <- hatvalues(res)
high_leverage <- ifelse(p_ii>2*2/30, data_1.9$River, "")
text(data_1.9$ComIndl, data_1.9$Nitrogen-0.1, high_leverage)

# 그림[4.6] - 표준화잔차의 인덱스플롯
plot(rstandard(res),pch=19)

# 그림[4.6] - 지레값의 인덱스플롯
plot(p_il,pch=19)
abline(h = 2*2/30, col = "red")

# 4,5번데이터 제외
res <- lm(Nitrogen~ComIndl,data = data_1.9[c(-4,-5),-1])
plot(Nitrogen~ComIndl,data = data_1.9[c(-4,-5),-1], pch = 19)
abline(res)

########### ---------------------------------------------------------------------------------------------------------------- ###########

########### 0504 ###########
### 4.9 영향력의 측도
## 4.9.1 Cook의 거리
res <- lm(Nitrogen~ComIndl,data = data_1.9)
plot(res,4) # 1보다 큰 값은 없지만 상대적인 위치를 봐야함

# 더 편리한 방법
library(olsrr)
ols_plot_cooksd_chart(res) #4번째값이 영향력을 많이 준다고 나타내고 있다.

## 4.9.2 Welsch & Kuh 의 측도
olsrr::ols_plot_dffits(res) #4번째 값이 영향력을 많이 준다고 나타내고 있다.

## 4.9.3 Hadi의 영향력 측도
# 전체적으로 봤을 때 대부분의 값들 중 크게 벗어난 값을 찾아줌
olsrr::ols_plot_hadi(res) # 5번째 값이 영향력을 많이 준다고 나타내고 있다.

## Residuals & Leverage & Cook's distance
plot(res, 5)

### 4.10 잠재성 - 잔차플롯
olsrr::ols_plot_resid_pot(res) # 모여있는 값들을 벗어난 값들을 탐색해야한다.

## 첨가변수플롯(added-variable plot), 편회귀플롯(partial regression plot)
res <- lm(Nitrogen~.,data = data_1.9[-1])

car::avPlots(res, pch = 19)

########### ---------------------------------------------------------------------------------------------------------------- ###########

########### 0509 ###########
## 사례 : 스코틀랜드 언덕 경주 데이터 p.126
data_4.5 <- read.table("./All_Data/P120.txt",header = T, sep = "\t")
dim(data_4.5)
head(data_4.5)
names(data_4.5)

##회전도표
library(rgl)
plot3d(x = data_4.5$Distance, y = data_4.5$Climb, z = data_4.5$Time)
with(data_4.5, plot3d(x=Distance, y = Climb, z = Time))

## 다중선형회귀적합
res <- lm(Time~Distance+Climb, data = data_4.5)
res
# Coefficients:
# (Intercept)     Distance        Climb  
# -539.4829     373.0727       0.6629  
# Time = -539.483 + 373.073 Distance + 0.662888 Climb
res_summ <- summary(res)
res_summ # 시간에 대한 변수로 거리와 경사는 영향을 준다.

## 첨가변수플롯(added-variable plot), 편회귀플롯(partial regression plot)
car::avPlots(res, pch = 19) # distance 18번 데이터는 멀리 떨어져있으므로 살펴 볼 필요가 있다./ climb 18번, 7번 데이터

## 성분잔차플롯(component plus residual plot), 편잔차플롯(partial residual plot)
# 비선형 여부를 판단하는 그래프 # 선이 거의 일치하면 저 변수는 선형적인 효과가 있다고 판단 / 곡선이면 비선형적이다고 볼 수 있음
car::crPlots(res, id = T, pch = 19) 

## 잠재성 - 잔차플롯
olsrr::ols_plot_resid_pot(res)

## Hadi의 영향력 측도
olsrr::ols_plot_hadi(res)

## Cook의 거리
olsrr::ols_plot_cooksd_chart(res)

### 4.14 로버스트회귀
library(MASS)

## 다중선형회귀적합
res <- lm(Time~Distance+Climb, data = data_4.5)
res

res_rlm <- MASS::rlm(Time~Distance+Climb, data = data_4.5)
res_rlm

summary(res)
summary(res_rlm) # p-value가 없음, 반복적인 수정으로 인해 분포를 모르기 때문

library(robustbase)
res_lmrob <- lmrob(Time~Distance+Climb, data = data_4.5)
res_lmrob
summary(res_lmrob) # p-value가 있음

########### ---------------------------------------------------------------------------------------------------------------- ###########

##### 5장 질적 예측변수#####
########### 0511 ###########
# install.packages("fastDummies")
library(fastDummies)

## 5.2 급료조사 데이터
data_5.1 <- read.table("./All_Data/P130.txt",header = T, sep = "\t")
names(data_5.1)
# "S": 급료(반응변수), "X" : 경력, "E" : 교육수준,  "M": 관리 형태 
table(data_5.1$E)
# 1: 고졸, 2: 대졸, 3: 대학원 이상
table(data_5.1$M)
# 0 : 관리자, 1 : 관리자 X

## 자료형 변경 : 정수 > 범주 # 숫자형 데이터가 아닌 범주형 데이터임
data_5.1$E <- as.factor(data_5.1$E)
data_5.1$M <- as.factor(data_5.1$M)
head(data_5.1)

data_5.1$E

## 가변수 생성
data_dummy <- dummy_cols(data_5.1,
                         select_columns = c("E","M"),
                         remove_first_dummy = T,
                         remove_selected_columns = T)
data_dummy
## 가변수 생성 (분석용)
data_5.1$E <- factor(as.character(data_5.1$E), levels = c("3","1","2")) #사용할 LEVEL을 앞으로 빼줌
data_5.1$M <- factor(as.character(data_5.1$M), levels = c("0","1"))
data_dummy <- dummy_cols(data_5.1,
                         select_columns = c("E","M"),
                         remove_first_dummy = T,
                         remove_selected_columns = T)
data_dummy

## 회귀분석(1) - 가변수 
res <- lm(S~.,data = data_dummy)
res
## 회귀분석(2) - lm()
res <- lm(S~., data = data_5.1) # 굳이 dummy를 사용하지 않아도 factor로 바꿔준다면 자동으로 가변수를 생성해준다.
res
summary(res)

## 표준화잔차 대 경력연수 p.142
plot(data_5.1$X, rstandard(res), pch= 19, xlab = "X", ylab = "잔차")
# 데이터가 3그룹으로 나눠진게 보임

########### ---------------------------------------------------------------------------------------------------------------- ###########

########### 0516 ###########
## 표준화잔차 대 교육수준-관리 조합
# S = beta_0 + beta_1*X + r1E1 + r2E2 + s1M + e
# S = 11,031 + 546*X - 2,996*E1 + 147*E2 + 6,883*M
# 고졸과 대졸의 차이  = 2,996 + 147
# E2의 p-value 가 0.05 보다 크므로 유의하지않은 변수라고 볼 수 있다. 즉 147은 0이라고 할 수 있다.

EM <- paste0(data_5.1$E, data_5.1$M)
plot(EM, rstandard(res),pch = 19, xlab = "범주", ylab = "잔차")

## 상호작용 효과(interactive effect)
res <- lm(S ~ X + E + M + E*M, data=data_5.1)
res
summary(res)

## 표준화잔차 대 경력연수
plot(data_5.1$X, rstandard(res), pch= 19, xlab = "X", ylab = "잔차")

## Cook의 거리
plot(res,4) ## 33번째 값이 많이 떨어져있음

## 상호작용 효과(interactive effect) - 관측 개체 33 제외
data_use <- data_5.1[-33,]
res <- lm(S~X+E+M+E*M, data=data_use)
res
summary(res)
# 상호작용 효과가 적용된 모형이 유의미하므로 상호작용 효과가 있다고 할 수 있음

## 표준화잔차 대 경력연수
plot(data_use$X, rstandard(res), pch= 19, xlab = "X", ylab = "잔차")

## 표준화잔차 대 교육수준-관리 조합
EM <- paste0(data_use$E, data_use$M)
plot(EM, rstandard(res),pch = 19, xlab = "범주", ylab = "잔차")
# 상호작용 효과가 적용된 모형이 더 잘 적합이 되었다는 것을 알 수 있음 

## 기본급료의 추정
res <- lm(S~X+E+M+E*M, data = data_use)
df_new <- data.frame(X=rep(0,6), # rep : 0을 6번 반복해라
                     E=rep(1:3,c(2,2,2)), # 1,2,3 을 2번씩 2번 반복해라
                     M=rep(c(0,1),3))  # 0,1을 3번 반복해라

## 가변수 생성 - 분석용
df_new$E <- factor(as.character(df_new$E), levels = c("3","1","2"))
df_new$M <- factor(as.character(df_new$M), levels = c("0","1"))
cbind(df_new, predict = predict(res, df_new, interval = "confidence"))
# 해석 : 평균적으로 ~~ 만큼 차이가 난다.
# ex) 고졸관리자일때 뭐랑 뭐를 더해야하는지 알아야함 **

### 5.4 회귀방정식의 체계 : 두 집단의 비교 

## [표 5.7] 고용 전 검사 프로그램 데이터 p.148
data_5.7 <- read.table("./All_Data/P140.txt",header = T, sep = "\t")
head(data_5.7)

## 5.4.1 다른 기울기와 다른 절편항을 가지는 모형
#모형1 Yij = beta_0 + beta_1*xij + eij # 통합모형 (인종간의 차이가 없을때 사용)
model_1 <- lm(JPERF~TEST, data = data_5.7)
summary(model_1) # Multiple R-squared:  0.5167 51퍼센트를 설명함

#모형3 yij = beta_0 + beta_1*xij + rzij + d(zij*xij) + eij
model_3 <- lm(JPERF~TEST+RACE+TEST*RACE, data = data_5.7) # 데이터 자체가 가변수라 factor사용X
summary(model_3) # Multiple R-squared:  0.6643 66퍼센트를 설명함 모형 3이 더 좋은 모형임, anova는 참고용이지 절대적인 것이 아님


# 모형비교 
## H_0:gamma=delta=0
anova(model_1,model_3) # 0.05보다 크므로 영가설 채택, 축소모형이 맞음 = 인종적 차별이 없다 볼 수 있음

## [그림 5.7] 표준화잔차 대 검사점수 : 모형1
plot(data_5.7$TEST, rstandard(model_1),
     pch = 19, xlab = "검사점수", ylab = "잔차",
     main = "[그림 5.7] 표준화잔차 대 검사점수 : 모형 1") 

## [그림 5.8] 표준화잔차 대 검사점수 : 모형3
plot(data_5.7$TEST, rstandard(model_3),
     pch = 19, xlab = "검사점수", ylab = "잔차",
     main = "[그림 5.8] 표준화잔차 대 검사점수 : 모형 3")

# 두 그림 모두 랜덤하게 잘 분포되어있음 , 모형 3을 써도댐

########### ---------------------------------------------------------------------------------------------------------------- ###########

########### 0518 ###########
## [그림 5.9] 표준화잔차 대 인종 : 모형1
plot(data_5.7$RACE, rstandard(model_1),
     pch = 19, xlab = "검사점수", ylab = "잔차",
     main = "[그림 5.9] 표준화잔차 대 인종 : 모형 1")

## 분리된 회귀분석 결과 (기울기가 다른 경우)
data_5.7_R1 <- subset(data_5.7,RACE==1)
model_R1 <- lm(JPERF~TEST, data = data_5.7_R1)
summary(model_R1) # 소수민족 : Y1 = 0.09712 + 3.31095X1

data_5.7_R0 <- subset(data_5.7,RACE==0)
model_R0 <- lm(JPERF~TEST, data = data_5.7_R0)
summary(model_R0) # 백인 : Y2 = 2.010 + 1.313X2        

## [그림 5.10] 표준화잔차 대 검사점수 : 모형1, 소수민족만
plot(data_5.7_R1$TEST, rstandard(model_R1),
     pch = 19, xlab = "검사점수", ylab = "잔차",
     main = "[그림 5.10] 표준화잔차 대 검사점수 : 모형1, 소수민족만")

## [그림 5.11] 표준화잔차 대 검사점수 : 모형1, 백인만
plot(data_5.7_R0$TEST, rstandard(model_R0),
     pch = 19, xlab = "검사점수", ylab = "잔차",
     main = "[그림 5.10] 표준화잔차 대 검사점수 : 모형1, 백인만")

# 그럭저럭 ㄱㅊ

### 적절한 합격점수의 결정 - 소수민족
## 고용 전 검사점수의 합격점에 대한 95% 신뢰구간
ym <- 4
xm <- (ym-0.09712)/3.31095 # 회귀계수 beta_0, beta_1
s <- 1.292 # 표준편차
n <- 10 # 10명
t <- qt(1-0.05/2,8) # t분포에서 자유도가 8일 때 0.025가 되는 상위분위수
c(xm-(t*s/n)/3.31095, xm+(t*s/n)/3.31095) #신뢰구간

### 5.4.2 동일한 기울기와 다른 절편항을 가지는 모형
model_3 <- lm(JPERF~TEST+RACE, data = data_5.7)
summary(model_3)
#               Estimate
# (Intercept)   0.6120  = beta_0  
# TEST          2.2988  = beta_1   
# RACE          1.0276  = r(감마?)


## H_0 : gamma(rho)  = 0
anova(model_1,model_3) # 0.05보다 크므로 영가설 채택. 즉, 통합모형이 낫다

## 소수민족(RACE==1):(0.6120 + 1.0276) + 2.2988*TEST = 1.6396 + 2.2988*TEST
# 백인(RACE==0): 0.6120 + 2.2988*TEST

### 5.4.3 동일한 절편항과 다른 기울기를 가지는 모형
model_3 <- lm(JPERF~TEST + I(TEST*RACE), data=data_5.7) # I() : 이 기능을 빼면 RACE라는 변수를 넣지도 않았는데 들어갈 수 있음
summary(model_3)

## H_0 : delta=0
anova(model_1,model_3) # p-value 가 0.05보다 작으므로 대립가설 채택 delta != 0, 즉, delta값이 있어야함 
# 모델을 가정할 수 있을 때 사용해야함

########### ---------------------------------------------------------------------------------------------------------------- ###########

########### 0523 ###########
### 6.3 X-선 방사에 의한 박테리아 사망률
data_6.2 <- read.table("./All_Data/P168.txt",header = T, sep = "\t")
dim(data_6.2)
head(data_6.2)

## [그림 6.5]
plot(N_t~t, data = data_6.2, pch = 19)

## 6.3.1 선형모형의 부적절성
res <- lm(N_t~t, data = data_6.2)
summary(res)

## [그림 6.6]
plot(data_6.2$t, rstandard(res),pch=19) # 적절한 회귀모형이 아님, 흩어져있지않음

### 6.3.2 선형성을 위한 로그 변환
# [그림 6.7]
plot(log(N_t)~t, data = data_6.2, pch=19)

res <- lm(log(N_t)~t, data = data_6.2) # 반응변수만 로그를 취하고 예측변수는 로그를 취하지 않음
summary(res)


# [그림 6.6]
plot(data_6.2$t, rstandard(res),pch=19) # 로그를 취하니 값들이 적절하게 흩어짐

#logn_0 = beta_0_hat ? 
#n_0의 값
exp(5.973160)
exp(coef(res)[1])
exp(coef(res)[1]-0.0588/2) #불편추정량 참고

# [그림 6.8]
plot(data_6.2$t, rstandard(res),pch = 19)

### 6.4 분산안정화 변환
## 항공사 사상사고 데이터
data_6.6 <- read.table("./All_Data/P174.txt",header = T, sep = "\t")
dim(data_6.6)
head(data_6.6)

plot(Y~N, data = data_6.6, pch = 19) # 분산이 점점 커지는 형태, 이분산성

# 변수 변환 없이 해봤을 때
# N에 대한 Y의 회귀
res_1 <- lm(Y~N, data = data_6.6)
summary(res_1)

# 표준화잔차 대 N의 플롯
plot(data_6.6$N, rstandard(res_1),pch = 19,
     xlab = "N", ylab = "잔차", main = "[그림 6.11]")
# 예상처럼 등분산성을 만족하지 않음

# 변수 변환 : 반응 변수에 루트 적용
# N에대한 sqrt(Y)의 회귀
# N에 대한 Y의 회귀
res_2 <- lm(sqrt(Y)~N, data = data_6.6)
summary(res_2)
# 불편성을 제거하지않으면(= 이분산성을 고정하지않으면 신뢰구간이 넓어짐) 표준오차가 커짐, 유의성 검정에 민감성이 떨어진다.
# 표준오차가 p-value?를 높여줌?


# 표준화잔차 대 N의 플롯
plot(data_6.6$N, rstandard(res_2),pch = 19,
     xlab = "N", ylab = "잔차", main = "[그림 6.12]")
# 잔차가 잘 퍼져있음을 확인할 수 있음 p.184

#선형성은 무조건 확인해줘야하지만 등분산성은 필수는 아님


### 6.5 이분산성의 검출
## 종업원과 감독자의 수
data_6.9 <- read.table("All_Data/P176.txt", header = T, sep = "\t")
dim(data_6.9)
head(data_6.9)
# 이분산성 확인하는법 : 잔차 플롯 그리기
# Y 대 X의 플롯
plot(Y~X, data = data_6.9, pch = 19, main = "[그림 6.13]")

# X에 대한 Y의 회귀
res_1 <- lm(Y~X, data = data_6.9)
summary(res_1)

# 표준화잔차 대 N의 플롯
plot(data_6.9$X, rstandard(res_1),pch = 19,
     xlab = "X", ylab = "잔차", main = "[그림 6.14]")


### 6.6 이분산성의 제거
# 변환된 Y/X와 1/X를 적합한 회귀
# 오차항의 변이가 관측값의 크기에 비례하는 경우
data_6.9_1 <- data.frame(Y = data_6.9$Y/data_6.9$X,
                         X = 1/data_6.9$X) # 원래 값의 역수
res_2 <- lm(Y~X, data = data_6.9_1)
summary(res_2) #p.187

# 표준화잔차 대 X의 플롯
plot(data_6.9_1$X, rstandard(res_2),pch = 19,
     xlab = "1/X", ylab = "잔차", main = "[그림 6.15]")

### 6.7 가중최소제곱법(안배울거라면서 배움)
wt <- 1/data_6.9$X^2
res_3 <- lm(Y~X, data = data_6.9, weights = wt)
summary(res_3)

########### ---------------------------------------------------------------------------------------------------------------- ###########

########### 0525 ###########
## 종업원과 감독자의 수
data_6.9 <- read.table("./All_Data/P176.txt",header = T, sep = "\t")
dim(data_6.9)
head(data_6.9)

## 데이터에 대한 로그 변환 (분석대상 변수가 그의 평균에 비해서 큰 표준편차를 가지고 있을 때)
# log(y) 대 x의 산점도
plot(log(Y)~X, data = data_6.9, pch =19, main = "[그림 6.16]")

res_4 <- lm(log(Y)~X, data = data_6.9)
summary(res_4) # R-squared:  0.7702

# X에 대한 log(Y)의 회귀로부터 얻은 표준화잔차플롯
plot(data_6.9$X, rstandard(res_4), pch = 19, xlab = "X", ylab = "잔차", main="[그림 6.17]")

res_5 <- lm(log(Y)~X+I(X^2),data = data_6.9)
summary(res_5) # R-squared:  0.8857

## 표준화잔차 대 적합값 플롯 : x와 x^2에 대한 log(Y)의 회귀 # 랜덤하게 흩어져있어야함
plot(fitted(res_5), rstandard(res_5),pch = 19 ,xlab = "X", ylab = "잔차", main="[그림 6.18]")

## 표준화잔차 대 x의 플롯 : x와 x^2에 대한 log(Y)의 회귀
plot(data_6.9$X, rstandard(res_5),pch = 19 ,xlab = "X", ylab = "잔차", main="[그림 6.19]")

## 표준화잔차 대 x^2의 플롯 : x와 x^2에 대한 log(Y)의 회귀
plot(data_6.9$X^2, rstandard(res_5),pch = 19 ,xlab = "X", ylab = "잔차", main="[그림 6.19]")

########### ---------------------------------------------------------------------------------------------------------------- ###########

########### 0530 ###########
### 제 9장 공선형 데이터의 분석
## 9.2 통계적 추론에 미치는 효과
data_9.1 <- read.table("./All_Data/P236.txt",header = T, sep = "\t")
dim(data_9.1)
head(data_9.1)

res <- lm(ACHV~., data = data_9.1)
summary(res) #회귀계수는 전부 의미 없게 나왔다.

# 산점도
panel.cor <- function(x, y){
        par(usr = c(0, 1, 0, 1))
        r <- round(cor(x, y), digits=3)
        text(0.5, 0.5, r, cex=1.5)
}
pairs(data_9.1[-1], lower.panel = panel.cor, main = "[그림 9.2]")



# 잔차 플롯 그림 9.1
plot(fitted(res), rstandard(res),pch=19,
     xlab = "예측값",ylab = "잔차", main = "[그림 9.1]")


## 9.3 예측에 미치는 효과
# 프랑스 경제 데이터
data_9.5 <- read.table("./All_Data/P241.txt",header = T, sep = "\t")
dim(data_9.5)
head(data_9.5)

# 산점도
pairs(data_9.5[-1], lower.panel = panel.cor)

# 회귀분석(1): 데이터 1949~1966
res <- lm(IMPORT~., data = data_9.5[-1])
summary(res)

# 그림 [9.3] 표준화 잔차의 인덱스플롯
plot(1:nrow(data_9.5), rstandard(res),pch = 19,type = "b",
     xlab = "번호", ylab = "잔차", main = "[그림 9.3]")

# 1960년도부터 가격이 엄청 상승함
# 회귀분석(2): 데이터 1949~1959
data_use <- subset(data_9.5, YEAR<=59)
res <- lm(IMPORT~., data = data_use[-1])
summary(res)

# 잔차 플롯 #랜덤하게 흩어져있으므로 모형은 괜찮다할 수 있음
plot(1:nrow(data_use), rstandard(res),pch = 19,type = "b",
     xlab = "번호", ylab = "잔차", main = "[그림 9.4]")

## 9.4 다중공산성의 탐색
# 분산확대인자(variance inflation factor; VIF)
library(olsrr)

# 교육기회균등 (EEO)
res_9.1 <- lm(ACHV~., data = data_9.1)
summary(res_9.1)

# car::vif(res_9.1)
olsrr::ols_vif_tol(res_9.1) # 각각의 변수에서 모두 다중공산성이 확인되었다.

# [표9.5] 프랑스 경제데이터 > 회귀분석(2):데이터 1949~1959
data_use <- subset(data_9.5, YEAR<=59)
res_9.5 <- lm(IMPORT~., data = data_use[-1])
#car::vif(res_9.5)
olsrr::ols_vif_tol(res_9.5) # 첫번째 변수와 세번째 변수가 다중공산성을 가지고 있다.

########### ---------------------------------------------------------------------------------------------------------------- ###########

########### 0608 ###########
### 주성분
pc <- prcomp(data_use[-c(1,2)], scale. = T)
pc$rotation

pc$x

### 주성분회귀
df <- data.frame(IMPORT = scale(data_use$IMPORT), pc$x)
df
res <- lm(IMPORT~., data = df)
summary(res)

########### ---------------------------------------------------------------------------------------------------------------- ###########

########### 0610 ###########
data_3.3 <- read.table("./All_Data/P060.txt",header = T, sep = "\t")
head(data_3.3)

### 분산확대인자(variance inflation factor; VIF): 10초과 > 심각한 공산성의 문제가 있음
res <- lm(Y~., data = data_3.3)
summary(res)
olsrr::ols_vif_tol(res)

### 수정결정계수(Adjusted R-squared)
res_summ <- summary(res)
res_summ$adj.r.squared

### Mallow's Cp # 값이 작을 수록 좋음
# 축소모형
res_subset <- lm(Y~X1+X3, data = data_3.3)
olsrr::ols_mallows_cp(res_subset, res)

### AIC(Akaike information criterion)
olsrr::ols_aic(res_subset, method = "SAS")

### BIC(Bayes information criterion)
olsrr::ols_sbic(res_subset, res)

### 전진적 선택 방법 - AIC
res_step <- step(res, direction = "forward")

### 후진적 제거 방법 - AIC
res_step <- step(res, direction = "backward")

### 단계적 방법
res_step <- step(res)
summary(res_step)

########### ---------------------------------------------------------------------------------------------------------------- ###########

########### 0613 ###########
## 연습문제 11.5 - 건물의 물리적 특성들과 건물에 대한 세금 정보를 활용하여 집의 판매가격을 예측
data_11.17 <- read.table("./All_Data/P329.txt",header = T, sep = "\t")
dim(data_11.17)
head(data_11.17)

### 데이터 탐색 - 자료형
sapply(data_11.17, class)

### 데이터 탐색 - 기초통계량
summary(data_11.17)

### 데이터 탐색 - 히스토그램 & 상자그림
hist(data_11.17$Y)
boxplot(data_11.17$Y)

### 데이터 탐색 - 산점도 행렬 & 상관계수
panel.cor <- function(x, y, digits = 2, prefix = "", cex.cor, ...)
{
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r <- abs(cor(x, y))
  txt <- format(c(r, 0.123456789), digits = digits)[1]
  txt <- paste0(prefix, txt)
  if(missing(cex.cor)) cex.cor <- 0.8/strwidth(txt)
  text(0.5, 0.5, txt, cex = cex.cor * r)
}
pairs(data_11.17, pch=19, lower.panel = panel.cor)

### (a) 모든 변수들이 모형에 포함시킬 것인가?

model_1 <- lm(Y~., data=data_11.17)
summary(model_1)
olsrr::ols_vif_tol(model_1)

### (b) 지방세(X1) 방의 수(X6), 건물의 나이(X8)가 판매가격(Y)을 설명하는 데 적절하다는 의견에 동의하는가?
model_2 <- lm(Y~X1+X6+X8, data=data_11.17)
summary(model_2)
#VIF
olsrr::ols_vif_tol(model_2)
# 회귀진단 그래프들
layout(matrix(1:4, nrow = 2, byrow = T))
plot(model_2)
layout(1)

# Cook의 거리
olsrr::ols_plot_cooksd_chart(model_2)


### 17번 제거
data_use <- model_5$model[-17,]
model_6 <- lm(Y~., data=data_use)
summary(model_6)
