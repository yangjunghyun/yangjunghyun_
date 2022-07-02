rm(list=ls())
data_2.5 <- read.table("All_Data/P031.txt", header = T,sep="\t")
res_lm <- lm(Minutes~Units, data= data_2.5)
res_lm

#검정결과 보기
res_lm_summ <- summary(res_lm)
res_lm_summ

#b0의 추정치 = estimate(Intercept) = 4.162
#b1의 추정치 = estimate(Units) = 15.509
#표준 오차 std.error
#t-value검정통계량#반응변수에 대한 p-value가 8.92x10의 마이너스 18승 유의수준 0.05 보다 작으므로 H1 대립가설 채택.
# 대립가설은 b1 != 0 즉, 15.509는 0이아니다. units은 수리시간에 15.5분정도의 영향을 준다.

###03-28###

###2.7신뢰구간
confint(res_lm)

###2.8예측
x <- 4
4.161654 + 15.508772 * 4
#tip
res_lm$coefficients[1] + res_lm$coefficients[2] * x

###predict()
df <- data.frame(Units = 4)
predict(res_lm,newdata =df )
#표준오차도 같이
predict(res_lm,newdata =df, se.fit= T)
res_lm_pred <- predict(res_lm,newdata =df, se.fit= T)
res_lm_pred

#예측값
res_lm_pred$fit

#평균반응(mean response)에 대한 추정치 - 표준오차
res_lm_pred$se.fit

#예측한계 # 그 값에 대한 추정값
df <- data.frame(Units = 1:10)
res_lm_pred_int_p <- predict(res_lm,newdata =df, interval = "prediction")
res_lm_pred_int_p

#신뢰한계 # 평균 반응에 대한 신뢰도 : 예측한계보다 값이 더 좋게 나옴.
df <- data.frame(Units = 1:10)
res_lm_pred_int_c <- predict(res_lm,newdata =df, interval = "confidence")
res_lm_pred_int_c

#예측한계와 신뢰한계
plot(Minutes~Units, data = data_2.5, pch =19)
abline(res_lm, col="red",lwd=2)
lines(1:10, res_lm_pred_int_p[,"lwr"],col = "darkgreen")
lines(1:10, res_lm_pred_int_p[,"upr"],col = "darkgreen")
lines(1:10, res_lm_pred_int_c[,"lwr"],col = "blue")
lines(1:10, res_lm_pred_int_c[,"upr"],col = "blue")

res_lm <- lm(Minutes~Units, data=data_2.5)
res_lm

# 결정계수 - R.squared
res_lm_summ
# Multiple R-squared:  0.9874 
# 전체의 변이 중 98.74%가 예측변수에 의해 설명 된다.
# 전체 변동의 98.74%가 회귀모형에 의해 설명 된다.
# 즉, Units이라는 변수가 전체의 98.74%를 설명하고 있다.


### 2.10 원점을 통과하는 회귀선 
# beta_0 = 0이고, Y=betaX 이므로 0,0 원점을 통과함 
res_lm_no <- lm(Minutes~Units -1, data = data_2.5)
res_lm_no

summary(res_lm_no) 

coef(summary(res_lm_no)) #p-value가 더 작아졌음 -> 더 정확해짐
# 절편이 있을 때 R.squared : 0.9874
# 절편이 없을 때 R.squared : 0.9975 


### 2.11 사소한 회귀모형
y <- rnorm(30)
# H0 : mu0 = 0
t.test(y,mu=0)
summary(lm(y~1)) # 1은 상수항

