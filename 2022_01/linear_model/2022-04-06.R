#20일 퀴즈 30분
#25일 시험 한시간
### 최소제곱 추정량의 성질
res_lm <- lm(Y~., data=data_3.3)
res_lm
summary(res_lm)

lm(Y~X1+X2+X3+X4+X5+X6, data = data_3.3) 
summary(lm(Y~X1+X2+X3+X4+X5+X6, data = data_3.3))
summary(lm(Y~X1+X2+X3+X4+X5, data = data_3.3))
###3.9 개별 회귀계수들에 대한 추론
#p-value가 작을 수록 영향력을 많이줌

res_lm_summ <- summary(res_lm)
res_lm_summ
# 모든 회귀계수들에 대한 검정 결과 0.05보다 작으므로 적어도 하나는 0이 아니라는 의미
# F-statistic:  10.5 on 6 and 23 DF,  p-value: 1.24e-05


### 회귀계수에 대한 신뢰구간 - 95% 신뢰한계
confint(res_lm) #0이 포함되어있는지 아닌지만 보면 댐

###########2022-04-11###########
data_3.3 <- read.table("All_Data/P060.txt", header = T,sep="\t")

### 3.10 선형모형에서의 가설검정
## 3.10.1. 모든 회귀계수들이 0인가에 대한 검정
# H_0: beta_1:beta_6=0
# beta_1:beta_6까지 0이라고 가정하였으므로 상수항만 있음 1
# 회귀모형에서 상수항은 beta_0
model_reduced <- lm(Y~1,data=data_3.3) 
model_full <- lm(Y~.,data=data_3.3)

# 분산분석표 이용 anova
anova(model_reduced, model_full)
# 1.24e-05 *** < 0.05 보다 작으므로 대립가설 채택 = 완전모형이 적절하다
# 즉, 의미있는 변수가 한 개 이상 존재한다.
# r로 결과를 뽑아내는 것보다 의미를 해석하는 것이 중요하다.

# FM의 summary에는 이미 F통계량이 나와있다.
summary(model_full)


## 3.10.2 회귀계수들의 부분집합이 0인가에 대한 검정
# H_0 : beta_2=beta_4:beta_6=0 # 영가설 채택 : X1과 X3는 반응변수에 유의한 영향을 준다.
model_reduced <- lm(Y~X1+X3,data=data_3.3)
model_full <- lm(Y~., data=data_3.3)

anova(model_reduced,model_full)
# p-value가 유의수준보다 크므로, 영가설 채택
# 즉, beta_1과 beta_3는 의미가 있다.

## 3.10.3 회귀계수들의 동일성에 대한 검정
# H_0 : beta_1=beta_3 | beta_2=beta_4: beta_6 = 0
# 조건부확률(B|A : A라는 조건 하에서 B의 확률은 얼마냐
model_full <- lm(Y~X1+X3,data = data_3.3)
model_reduced <- lm(Y~I(X1-X3),data = data_3.3) # I : 그대로

anova(model_reduced,model_full)



# install.packages("car")
library(car)
model_full <- lm(Y~X1+X3,data = data_3.3)
car::linearHypothesis(model_full,c("X1 = X3"))
# p-value 가 0.05보다 크다, 영가설 채택.

# model_full <- lm(Y~.,data = data_3.3)
# car::linearHypothesis(model_full,c("X1 = X3"))

## 3.10.4 제약조건하에서 회귀계수에 대한 추정과 검정
# H_0 : beta_1+beta_3=1 | beta_2=beta_3: beta_6 = 0
model_full <- lm(Y~X1+X3,data = data_3.3)
car::linearHypothesis(model_full,c("X1 + X3 = 1"))
# p-value 가 0.05보다 크다, 영가설 채택.
# 영가설 : beta_2,beta_4:beta_6이 모두 효과가 없을때
# beta_1과 beta_3의 효과는 있다. 더한 효과는 1이다.
# X1의 효과가 증가하면 X3의 효과는 감소한다.
# 두개의 효과 합을 1이라고 할 수 있다.


### 3.11 예측
model_full <- lm(Y~.,data=data_3.3)

## 예측값 - 적합값
model_full$fitted.values

## 예측한계 (Prediction Limit, Forecast Limit)
predict(model_full, newdata = data_3.3, interval = "prediction")


## 신뢰한계 (Confidence Limit)
predict(model_full, newdata = data_3.3, interval = "confidence")

#95페이지

###########2022-04-13###########
Y <- data_3.3$Y
X <- data_3.3[,-1]
X <- cbind(1,X)
X <- as.matrix(X)

# beta_hat <- solve(t(X) %*% X) %*% t(X) %*% Y # %*%: 행렬 곱하기, solve: 역행렬
P <- solve(t(X) %*% X) %*% t(X)
beta_hat <- P %*% Y

lm(Y~., data=data_3.3)

###########2022-04-18###########
### 제 4장 회귀진단 :  모형위반의 검출
## 4.3 다양한 유형의 잔차들
# 표준화 잔차
data_3.3 <- read.table("All_Data/P060.txt", header = T,sep="\t")
head(data_3.3)

res_lm <- lm(Y~., data=data_3.3)
class(res_lm)
# 무슨 구조의 형태인지.
mode(res_lm)
# 리스트의 이름들
names(res_lm)
# 전체적인 구조를 보여주는 함수
str(res_lm)

# 잔차
res_lm$residuals
resid(res_lm)

# 내적 표준화잔차
rstandard(res_lm)

# 외적 표준화잔차
MASS::studres(res_lm)


# 잔차
resid_df <- data.frame(
  Y = data_3.3$Y,
  Y_hat = res_lm$fitted.values,
  resid = resid(res_lm),
  rstandard = rstandard(res_lm),
  studres = MASS::studres(res_lm)
)
resid_df


### 4.4 그래프적 방법들
## 4.5 모형을 적합하기 이전의 그래프
# 4.5.1 일차원 그래프
x <- rnorm(100,70,10)
# 히스토그램(histogram)
hist(x)
hist(x, breaks = 5) # 몇번 자를건지
# 줄기, 잎 그림 (stem and leaf display)
# 모든 데이터를 다 볼 수 있고, 분포도 다 볼 수 있다.
# 단점 : 데이터가 많으면 의미가 없다.
stem(x)
stem(round(x))
stem(round(x),scale = 2) #scale=2 : 기존 그래프에서 2배 늘림
# 점플롯(산점도) dot plot
idx <- rep(1, length(x))
plot(idx,x)
plot(jitter(idx),x,xlim = c(0.5,1.5)) # jitter 흩어지게해줌.

# 상자그림 (box plot)
boxplot(x)
points(jitter(idx),x) #상자플롯+점플롯

# 4.5.2 이차원 그래프
# 표 4.1 - Hamilton의 데이터
data_4.1 <- read.table("All_Data/P103.txt", header = T,sep="\t")
dim(data_4.1)
class(data_4.1)

# 산점도 행렬
plot(data_4.1)
# cor(data_4.1)
pairs(data_4.1)

# 산점도와 correlation
# Correlation panel
panel.cor <- function(x, y){
  par(usr = c(0, 1, 0, 1))
  r <- round(cor(x, y), digits=3)
  text(0.5, 0.5, r, cex=1.5)
}
pairs(data_4.1, lower.panel = panel.cor)

# 4.5.3 회전도표 & 4.5.4 동적그래프
# install.packages("rgl")
library(rgl)
plot3d(x = data_4.1$X1, y= data_4.1$X2, z = data_4.1$Y)
with(data_4.1, plot3d(x=X1, y=X2, z =Y))


####################중간고사 시험범위####################
