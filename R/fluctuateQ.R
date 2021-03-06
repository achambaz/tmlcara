fluctuateQ  <-  function(#Fluctuates  the  Conditional Expectation  of  Y  Given (A,W).
### Function  for the  fluctuation of  the conditional  expectation  of \eqn{Y}
### given \eqn{(A,W)}, aka 'Q'.
                         obs, ### A \code{data.frame} of observations, as produced by \code{getSample}.
                         Qtab, ### A \code{matrix} of  conditional means of \eqn{Y} given  \eqn{(A,W)} at the
### observations as they are currently estimated.
                         GAstarW, ### The   \code{vector}   whose   \eqn{i}th   component  is   the   likelihood
### \eqn{Gstar(A_i|W_i)},  where \eqn{Gstar}  is the  current estimate  of the
### optimal treatment mechanism within the given parametric model.
                         what, ### A \code{character} indicating the parameter
### of interest to  estimate.  Either "ATE" for Average  Treatment Effect, the
### difference between the means under '\eqn{do(A=1)}' and '\eqn{do(A=0)}', or
### "MOR" for the Mean under the Optimal treatment Rule '\eqn{do(A=r(W))}'.
                         weights, ### The \code{vector} of weights upon which the estimation procedure relies.
                         Qmin, ### A \code{numeric},  used to  rescale the values  of the outcome  \eqn{Y} by
### using the scaling \code{function} \code{scaleY}.
                         targetLink=NULL, ### An  object of  class 'link-glm'  used to  fluctuate 'Q'.  Defaults to
### 'NULL', in which case the 'logit' link is used.
                         ..., ### Additional parameters.
                         verbose=FALSE ### A \code{logical}  or an \code{integer}  indicating the level  of verbosity
### (defaults to 'FALSE').
                         ) {
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## Validate arguments
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
  ## Argument 'obs'
  obs <- validateArgumentObs(obs)

  ## Argument 'Qtab'
  Qtab <- Arguments$getNumerics(Qtab)

  ## Argument 'GAstarW'
  GAstarW <- Arguments$getNumerics(GAstarW)
  
  ## Argument 'weights'
  weights <- Arguments$getNumerics(weights, c(0, Inf))

  ## Argument 'Qmin'
  Qmin <- Arguments$getNumeric(Qmin, c(0, 1/4))
  
  ## Argument 'verbose'
  verbose <- Arguments$getVerbose(verbose)

  ## Preparing 'family'
  if (is.null(targetLink)) {
    family <- binomial(link="logit")
  } else {
    family <- binomial(link=targetLink)
  }
  
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## Core
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
  Y <- obs[, "Y"]
  wrt <- range(Y, Qtab[, "A"])
  QA <- scaleY(Qtab[, "A"], wrt=wrt, thr=Qmin)
  Y <- scaleY(Y, wrt=wrt, thr=Qmin)
  A <- obs[, "A"]
  GA <- GAstarW
  if (what=="ATE") {
    HA <- (2*A-1)/GA
  } else if (what=="MOR"){
    rA <- as.numeric((Qtab[, "A=1"]-Qtab[, "A=0"])>0)
    HA <- (A==rA)/GA
  }
  
  fit <- glm(formula(Y~HA-1), data=data.frame(Y=Y, HA=HA),
             offset=family$linkfun(QA),
             family=family, weights=weights)
  eps <- coef(fit)
  
  return(eps)
### Returns \code{eps}, the \code{numeric} optimal fluctuation parameter. 
}


############################################################################
## HISTORY:
## 2016-09-16
## o Created.
############################################################################

