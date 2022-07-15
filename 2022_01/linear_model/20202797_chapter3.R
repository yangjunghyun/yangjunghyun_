data_3.3 <- read.table("All_Data/P060.txt", header = T,sep="\t")
data_3.3
# 1) Y에서 X1 효과 제거 표기법: e_hatY.X1
m1 <- lm(Y~X1, data=data_3.3)
m1$residuals

# 2) X2에서 X1 효과 제거 표기법: e_hatX2.X1
m2 <- lm(X2~X1, data=data_3.3)
m2$residual

## Y' = beta_0 + beta_1 * X2' + e
lm(m1$residuals~m2$residuals-1)
