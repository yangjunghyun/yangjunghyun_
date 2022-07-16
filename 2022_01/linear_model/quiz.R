# 기초통계 예제문제
# 단순선형 회귀모형
X <- c(168,160,170,158,176,161,180,183,180,167,179,171,166)
Y <- c(179,169,180,160,178,170,183,187,179,172,181,173,165)
# colname <- c("Dad","Son")
df <- data.frame(X,Y)

#beta0과 beta1의 추정치
beta1_hat <- sum((Y-mean(Y))*(X-mean(X))) / sum((X-mean(X))^2)
beta0_hat <- mean(Y) - beta1_hat * mean(X)
beta1_hat
beta0_hat
lm(Y~X)
#beat_0 = 37.8090 , beta_1 = 0.8042 : 회귀계수

# 산점도 및 회귀선
plot(X,Y)
abline(37.8090,0.8042)

# 적합값(fitted value)
Y_hat <- beta0_hat + beta1_hat * X
Y_hat

# 최소제곱잔차
e <- Y - Y_hat
e
sum(e)

#
res_lm <- lm(Y~X)
res_lm

# 회귀계수
# X1이 1단위 증가할 때마다 y가 회귀계수(beta_1hat)만큼 증가한다.
res_lm$coefficient
coef(res_lm)

# 최소제곱잔차
res_lm$residuals
resid(res_lm)
residuals(res_lm)

#검정결과 보기
res_lm_summ <- summary(res_lm)
res_lm_summ

#신뢰구간
round(confint(res_lm,level=0.95),2) # -13.2251717 ~ 88.843122

#예측값
x <- 4
res_lm$coefficients[1] + res_lm$coefficients[2] * x

# predict()
df <- data.frame(X = 4)
predict(res_lm,newdata =df )
#표준오차도 같이
res_lm_pred <- predict(res_lm,newdata =df, se.fit= T)
res_lm_pred

#예측값
res_lm_pred$fit

#평균반응(mean response)에 대한 추정치 - 표준오차
res_lm_pred$se.fit


#예측한계 # 그 값에 대한 추정값
df <- data.frame(X = 1:10)
res_lm_pred_int_p <- predict(res_lm,newdata =df, interval = "prediction")
res_lm_pred_int_p

#신뢰한계 # 평균 반응에 대한 신뢰도 : 예측한계보다 값이 더 좋게 나옴.
res_lm_pred_int_c <- predict(res_lm,newdata =df, interval = "confidence")
res_lm_pred_int_c

#예측한계와 신뢰한계
# m <- matrix(1:4,ncol=2,byrow=T)
# layout(m)
plot(Y~X, data = df, pch =19)
abline(res_lm, col="red",lwd=2)
lines(1:10, res_lm_pred_int_p[,"lwr"],col = "darkgreen")
lines(1:10, res_lm_pred_int_p[,"upr"],col = "darkgreen")
lines(1:10, res_lm_pred_int_c[,"lwr"],col = "blue")
lines(1:10, res_lm_pred_int_c[,"upr"],col = "blue")
# layout(1) #원상태로 그래프를 하나씩 그림
