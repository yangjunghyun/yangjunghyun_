data_3.3 <- read.table("All_Data/P060.txt", header = T,sep="\t")

plot(data_3.3)

###04-04###

#상수항을 추가하지 않았지만 자동적으로 상수항이 추가가 되어있음
lm(Y~X1+X2+X3+X4+X5+X6, data = data_3.3) 
lm(Y~., data = data_3.3)

### 3.5 회귀계수에 대한 해석
lm(Y~X1+X2, data = data_3.3) # X1 = 0.78034   X2 = -0.05016 

# 1) Y에서 X1 효과 제거 표기법: e햇Y.X1
m1 <- lm(Y~X1, data=data_3.3)
#잔차에 집중 (X1이 설명하지 못한 값)
# = Y가 가지고 있는 값들 중 X1에 대한 정보를 제외한 값
m1$residuals # X1의 효과가 제거된 Y = 새로운 Y'

# 2) X2에서 X1 효과 제거 표기법: e햇X2.X1
m2 <- lm(X2~X1, data=data_3.3)
m2$residuals # X1의 효과가 제거된 X2 = 새로운 X2'

## Y' = beta_0 + beta_1 * X2' + e

# 3) X1의 효과가 제거된 Y와 X2의 적합 - 원점을 지나는 회귀선
lm(m1$residuals~m2$residuals-1) #원점을 지나는 회귀는 -1
# m2$residuals  = -0.05016 위의 X2와 같음   

### 단위길위 척도화
fn_scaling_len <- function(x){
  x0 <- x - mean(x)
  x0 / sqrt(sum(x0^2))
}
data_3.3_len <- sapply(data_3.3,fn_scaling_len)
data_3.3_len <- data.frame(data_3.3_len)
summary(data_3.3_len)
lm(Y~., data=data_3.3_len)

#표준화 (scale) 를 하면
x <- rnorm(100,10,5) #rnorm(n,mean,sd)
x
x_std <- scale(x)
mean(x_std) #평균은 0에 가까워짐
sd(x_std) #표준편차는 1

data_3.3_std <- scale(data_3.3)

# data_3.3_std의 형태가 matrix이므로 sapply를 사용하기 위해
# dataframe으로 바꾸어줘야한다.
data_3.3_std <- data.frame(data_3.3_std)
# summary(data_3.3_std) # 표준화를 하여 평균이 0이 되었고,
# sapply(data_3.3_std,sd) # 표준편차가 1이 되었다.
lm(Y~.,data=data_3.3_std)

#최소제곱추정량의 성질 4가지

### 최소제곱 추정량의 성질
res_lm <- lm(Y~., data=data_3.3)
res_lm
summary(res_lm)

lm(Y~X1+X2+X3+X4+X5+X6, data = data_3.3)
summary(lm(Y~X1+X2+X3+X4+X5+X6, data = data_3.3))
summary(lm(Y~X1+X2+X3+X4+X5, data = data_3.3))
# 수정결정계수가 더 높기때문에 X6가 들어가있는 모형이 더 좋다.
# adjusted R-squared