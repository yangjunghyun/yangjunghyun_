data_concret <- read.table("All_Data/Concrete_Data_Yeh.txt", header = T,sep="\t")
head(data_concret)
names(data_concret)

data_use <- data_concret

### (1) 콘크리트의 강도(csMPa)에 대한 히스토그램(histogram)과 상자그림(box plot)을 그리고 분포에 대하여 설명하시오.
hist(data_use$csMPa)
boxplot(data_use$csMPa)
#이상치가 존재할 수 있으며 아래로 치우쳐져있다.


### (2) 모든 변수에 대한 산점도와 상관계수를 구하시오.
# Correlation panel
panel.cor <- function(x, y){
  par(usr = c(0, 1, 0, 1))
  r <- round(cor(x, y), digits=3)
  text(0.5, 0.5, r, cex=1.5)
}
pairs(data_use, lower.panel = panel.cor)

### (3) 시멘트 함량(cement)으로부터 콘크리트의 강도(csMPa)를 예측하기 위한 회귀선을 적합하시오.
res <- lm(csMPa~cement, data=data_concret)
res
# 13.44253      0.07958

### (4) 시멘트 함량(cement)이 콘크리트의 강도(csMPa)에 영향을 준다고 할 수 있는지 유의수준 0.05 하에서 검정하시오. (유의확률 p-value 제시)
res_summ <- summary(res)
res_summ
## res_lm_summ$coefficients ##1.324183e-65
# p-value가 유의수준 0.05보다 작으므로 영향을 준다고 할 수 있다.

### (5) 시멘트 함량(cement)이 10 증가하면 콘크리트의 강도(csMPa)는 평균적으로 얼마나 영향을 받는가?
0.079580*10 
# res_summ$coefficients[2]*10
# 0.79만큼 증가한다.

### (6) 콘크리트의 강도(csMPa)의 변이 중 시멘트 함량(cement)에 의하여 설명되는 비율은 얼마인가?
res_summ$r.squared
# 약 24.78퍼센트

### (7) 시멘트 함량(cement)이 500일 때, 콘크리트의 강도(csMPa)의 예측값과 95% 신뢰한계(Confidence Limit)를 구하시오.
# 1. 
predict(res, newdata = data.frame(cement=500), interval = "confidence")
# 2.
df <- data.frame(X1 = c(500))
predict(res_lm,newdata =df, se.fit= T)

### (8) 3개의 예측변수(cement, water, age)와 콘크리트의 강도(csMPa)를 관계시키는 회귀선을 적합하시오.
res_m <- lm(csMPa~., data=data_concret)
res_m

### (9) 3개의 예측변수(cement, water, age)에 의하여 설명되는 콘크리트의 강도(csMPa)의 변이는 몇 %인가?
res_m_summ <- summary(res_m)
res_m_summ$r.squared

### (10) 위 (8) 모형에서 시멘트 함량(cement)이 콘크리트의 강도(csMPa)에 영향을 준다고 할 수 있는지 유의수준 0.05 하에서 검정하시오. (유의확률 p-value 제시)
res_m_summ$coefficients

# 회귀계수 검정
model_full <- lm(csMPa~., data=data_concret)
model_reduced <- lm(csMPa~water+age, data=data_concret)
res_anv <- anova(model_reduced, model_full)
res_anv$`Pr(>F)`
