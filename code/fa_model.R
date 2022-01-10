# write a defined function to fit factor analytic model of any order
cat("\n Fitting model with custom function","\n")

fa_model <- function(k, kinv, Gparam, Rparam){
  eval(substitute(fa.fit <- asreml(fixed=fyld~env/set + prop_hav,
                                   random=~at(env):(set:rep) + vm(gen,kinv):fa(env, k),
                                   residual=~dsum(~units|env),
                                   na.action=na.method(y='include',x='include'),
                                   data = pheno, maxit = 50, G.param = Gparam,  R.param = Rparam,
                                   workspace = 250e6)))

  fa.fit <-  update.asreml(fa.fit)

  # extract  the goodness of fit statistics and variance component
  fa.fitstat <- infoCriteria(fa.fit)
  fa.vars <- as.data.frame(summary(fa.fit)$varcomp[,1:3])


  # extract out error variances from the fitted model
  error.vars <- fa.vars[grep("env_.*R", rownames(fa.vars)),1,drop=F]
  error.vars$env  <- substr(rownames(error.vars), start=5, stop=16)
  error.vars$env  <-  gsub("!R", "", error.vars$env)
  error.vars <- error.vars %>% rename(error.var=component) %>%
    mutate(env = as.factor(env)) %>% select(env, error.var)

  # extract out the  predicted yield value from GxE interaction
  #fa.predict <-  predict(fa.fit, data = dat, classify = "env:gen",maxitr=1)$pvals

  # extract out the E-BLUPs from the fitted model
  fa.blup <- summary(fa.fit, coef=TRUE)$coef.random
  fa.blup  <- fa.blup[grep("vm",rownames(fa.blup)),1:2, drop=F]
  rownames(fa.blup) <- gsub("vm\\(gen, Hinv\\)_|:fa\\(env, .\\)", "", rownames(fa.blup))
  gen_blup <- fa.blup[-grep("Comp*", rownames(fa.blup)),]
  temp  <- strsplit(rownames(gen_blup), "_")
  temp <- matrix(unlist(temp), ncol=2, byrow=TRUE)
  colnames(temp) <- c("gen", "env")

  eblups <- data.frame(env = temp[,"env"], gen=temp[,"gen"], blup = gen_blup[,1], std.error = gen_blup[,2])
  rownames(eblups) <- NULL
  eblups <- eblups[order(eblups$env),]

  # extract out the intercept from the fitted model
  fa.intercept <- summary(fa.fit, coef=TRUE)$coef.fixed
  fa.intercept <- fa.intercept[grep("(Intercept)",rownames(fa.intercept)),1, drop=F]

  #  Put all outputs together as a list object
  fa.output = list(fa.fit = fa.fit, fa.fitstat = fa.fitstat,  fa.vars = fa.vars,
                   error.vars = error.vars, fa.blup = eblups, fa.intercept=fa.intercept)
  return(fa.output)
}



