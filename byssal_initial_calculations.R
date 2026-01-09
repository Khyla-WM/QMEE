# "Substantive calculation using" byssal data

## Read in the dataset, name it
Byssal <- read.csv("Meta analysis workshop - byssal thread data.csv")

## Get basic summary statistics to review
summary(Byssal)

## Calculate the effect size and make a new column, as described in Clements & George 2022
Byssal$log_response_ratio <- log(Byssal$oa.mean / Byssal$ctrl.mean)

## Create plots to understand the data more in relation to our biological questions
plot(x = Byssal$Exp..Temp., y = Byssal$log_response_ratio)
abline(lm(log_response_ratio ~ Exp..Temp., data = Byssal))

plot(x = Byssal$pH.offset, y = Byssal$log_response_ratio)
abline(lm(log_response_ratio ~ pH.offset, data = Byssal))

plot(x = Byssal$Mean.shell.length, y = Byssal$log_response_ratio)
abline(lm(log_response_ratio ~ Mean.shell.length, data = Byssal))

boxplot(log_response_ratio ~ Food.amount, data = Byssal)

boxplot(log_response_ratio ~ Country, data = Byssal)

boxplot(log_response_ratio ~ Climate, data = Byssal)