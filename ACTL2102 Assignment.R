library(ggplot2)
library(goftest)
library(nortest)
library(fitdistrplus)


Data<- data.frame(
  Month=c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"),
  No.of.days=c(31,28,31,30,31,30,31,31,30,31,30,31),
  No.of.policies=c(15,20,20,25,30,30,35,40,50,50,50,60),
  No.of.claims=c(290,382,270,352,392,307,326,442,732,759,912,1203)
)

#Cumulative Actual Claims
Data$No.of.claims.cum<-t(t(cumsum(Data$No.of.claims)))

#Cumulative No. of days
#Data$No.of.days.cum<-t(t(cumsum(Data$No.of.days)))

#Function to do repetitive simulation to find claims count
Tf<-function(l,t,n){
  #l=lambda, t= period of time in days, n = number of simulations
  a<-0 #Set up number of simulation
  Claims<- c() #a vector containing claims count
  while(a<n){ #repeat doing simulation as long as number of simulation < specified maximum number
    lambda<-l
    t.length<-t
    arr.time<- c() #Vector of arrival time
    last.arr<-0 #Set up latest arrival
    inter.arr<-rexp(1,lambda*t) #simulate first inter_arrival time
    
    #simulate inter-arrival time
    while (inter.arr+last.arr<t.length) {
      last.arr<-inter.arr+last.arr
      arr.time<-c(arr.time, last.arr)
      inter.arr<-rexp(1,lambda)
    }
    Claims<-c(Claims,length(arr.time)) #Claims count updated
    a<-a+1 #do next simulation
  }
  Claims #return value of claims
}


#Task 1.1 Three Trajectories of Homogeneous and Non-Homogeneous Counting Process of Claims Counts
#Homogeneous Poisson Process
#Find the number of Simulations required
h.sample<-mapply(Tf,17.44,Data$No.of.days,30)
h.sample<-t(h.sample)
h.m<-apply(h.sample,1,mean)
h.s<-apply(h.sample,1,sd)
h.SimNo<-t(rbind(h.m,h.s))

#No. of simulations To estimate of distribution mean to be within 0.5% of the true value with probability of 95%
h.n<-(1.96*h.s/(0.005*h.m))^2 
h.SimNo<-cbind(h.SimNo,h.n)
h.n.Optimum<-as.integer(max(h.n)) #509


#Find the amount of claims per month for n trajectories per months
h.Sim<-mapply(Tf,17.44,c(31,28,31,30,31,30,31,31,30,31,30,31),h.n.Optimum)
h.Sim<-t(h.Sim) #each rows are monthly simulation (e.g.row 1= Jan)
colnames(h.Sim)<-colnames(h.Sim, do.NULL=FALSE,prefix = "Sim")

#Plot 3 Trajectories, Range of Simulations and Actual Claims

#Min, mean, and max values of the simulations
h.Sim.maxcum<-apply((apply(h.Sim,2,cumsum)),1,max)
h.Sim.mincum<-apply((apply(h.Sim,2,cumsum)),1,min)

#Extract 3 Homogeneous Cumsum Trajectories from the Simulations
h.3Traj<-cumsum(data.frame(h.Sim[,c(1:3)]))

#Set up dataframe to plot distributions
h.Sim.Traj<-Data[,-c(2,3)]
h.Sim.Traj<-cbind(h.Sim.Traj,h.Sim.mincum,h.Sim.maxcum)
h.Sim.Traj<-cbind(h.Sim.Traj,h.3Traj)

#Create directory to store plots
dir.create("Figures")

#Plot the cumulative 3 Homogeneous Trajectories and Range of Simulations, and Actual claims
png(filename = "Figures/Fig1.1.1.png",width=800,height=600,res=120)
ggplot(data=h.Sim.Traj,aes(group=1, x=Month))+
  geom_point(aes(y=Sim1,color="Trajectory1"))+ geom_line(aes(y=Sim1,color="Trajectory1"))+
  geom_point(aes(y=Sim2,color="Trajectory2"))+ geom_line(aes(y=Sim2,color="Trajectory2"))+
  geom_point(aes(y=Sim3,color="Trajectory3"))+ geom_line(aes(y=Sim3,color="Trajectory3"))+
  geom_point(aes(y=No.of.claims.cum,color="Actual"))+ geom_line(aes(y=No.of.claims.cum,color="Actual"))+
  geom_ribbon(aes(ymin=h.Sim.mincum,ymax=h.Sim.maxcum,fill=h.Sim.mincum > h.Sim.maxcum),alpha=0.3)+
  scale_fill_manual(values="Pink")+scale_x_discrete(limits=h.Sim.Traj$Month)+
  labs(y="Cumulative Claims",title="Homogeneous Poisson Trajectories vs Actual Claims", color="Legend",fill="Range")
dev.off()

#Variance reduction
  #Boxplot to compare variability before and after variance reduction technique used
png(filename = "Figures/Appendix1.png",width=1200,height=1200,res=120)
par(mfrow=c(2,1))
boxplot(h.Sim,use.cols = FALSE,names=c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"),main="Simulated Number of Claims per Month after Variance Reduction")
boxplot(h.sample,use.cols = FALSE,names=c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"),main="Simulated Number of Claims per Month before Variance Reduction")
dev.off()

#Calculate the standard deviations per month for before and after variance reduction technique used
h.Sim.sd<-apply(h.Sim,1,sd)
h.sd<-cbind(h.Sim.sd,h.s)
#Compare the variability of standard deviations for before and after variance reduction technique used
summary(h.Sim.sd)
summary(h.sd)

#MODEL 2 NON-HOMOGENEOUS POISSON PROCESS
#Define lamda for Non-homogeneous Case
nh.lambda<-c(11.02,11.02,11.68,11.68,11.68,26.41,26.41,26.41,20.83,20.83,20.83,11.02)

#Simulate Non-homogeneous Poisson
#Find the Number of Simulations required
nh.sample<-mapply(Tf,nh.lambda,Data$No.of.days,30)
nh.sample<-t(nh.sample)
nh.m<-apply(nh.sample,1,mean)
nh.s<-apply(nh.sample,1,sd)
nh.SimNo<-t(rbind(nh.m,nh.s))

#No. of simulations to estimate of distribution mean to be within 0.5% of the true value with probability of 95%
nh.n<-(1.96*nh.s/(0.005*nh.m))^2 
nh.SimNo<-cbind(nh.SimNo,nh.n)
nh.n.Optimum<-as.integer(max(nh.n))

#Find the amount of claims per month for n trajectories per months
nh.Sim<-mapply(Tf,nh.lambda,Data$No.of.days,nh.n.Optimum)
nh.Sim<-t(nh.Sim)
colnames(nh.Sim)<-colnames(nh.Sim, do.NULL=FALSE,prefix = "Sim")

#Plot the cumulative 3 Non-Homogeneous Trajectories, Range of Simulations, and Actual claims

#Min, mean, and max values of the Non-Homogeneous Simulations
nh.Sim.maxcum<-apply((apply(nh.Sim,2,cumsum)),1,max)
nh.Sim.mincum<-apply((apply(nh.Sim,2,cumsum)),1,min)

#Extract 3 Non-Homogeneous Cumsum Trajectories from the Simulations
nh.3Traj<-cumsum(data.frame(nh.Sim[,c(1:3)]))

#Set up dataframe to plot distributions
nh.Sim.Traj<-Data[,-c(2,3)]
nh.Sim.Traj<-cbind(nh.Sim.Traj,nh.Sim.mincum,nh.Sim.maxcum)
nh.Sim.Traj<-cbind(nh.Sim.Traj,nh.3Traj)

#Plot the cumulative 3 Trajectories, Range and Actual claims
png(filename = "Figures/Fig1.1.2.png",width=800,height=600,res=120)
ggplot(data=nh.Sim.Traj,aes(group=1, x=Month))+
  geom_point(aes(y=Sim1,color="Trajectory1"))+ geom_line(aes(y=Sim1,color="Trajectory1"))+
  geom_point(aes(y=Sim2,color="Trajectory2"))+ geom_line(aes(y=Sim2,color="Trajectory2"))+
  geom_point(aes(y=Sim3,color="Trajectory3"))+ geom_line(aes(y=Sim3,color="Trajectory3"))+
  geom_point(aes(y=No.of.claims.cum,color="Actual"))+ geom_line(aes(y=No.of.claims.cum,color="Actual"))+
  geom_ribbon(aes(ymin=nh.Sim.mincum,ymax=nh.Sim.maxcum,fill=h.Sim.mincum > h.Sim.maxcum),alpha=0.3)+
  scale_fill_manual(values="Pink")+scale_x_discrete(limits=nh.Sim.Traj$Month)+
  labs(y="Cumulative Claims",title="Non-Homogeneous Poisson Trajectories vs Actual Claims", color="Legend",fill="Range")
dev.off()

#Variance reduction
  #Boxplot to compare variability before and after variance reduction technique used
png(filename = "Figures/Appendix2.png",width=1200,height=1200,res=120)
par(mfrow=c(2,1))
boxplot(nh.Sim,use.cols = FALSE,names=c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"),main="Simulated Number of Claims per Month after Variance Reduction")
boxplot(nh.sample,use.cols = FALSE,names=c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"),main="Simulated Number of Claims per Month before Variance Reduction")
dev.off()
  #Calculate the standard deviations per month for before and after variance reduction technique used
nh.Sim.sd<-apply(nh.Sim,1,sd)
nh.sd<-cbind(nh.Sim.sd,nh.s)
  #Compare the variability of standard deviations for before and after variance reduction technique used
summary(nh.Sim.sd)
summary(nh.sd)

#Task 1.2 Distributions of Total Claims Count

#HOMOGENEOUS POISSON PROCESS
#Total claims of each Simulations
h.Sim.Total<-data.frame(colSums(h.Sim))
colnames(h.Sim.Total)<-"TotalClaims"

#Density of Total Claims in 1 year
png(filename = "Figures/Fig1.2.1.png",width=800,height=600,res=120)
ggplot(h.Sim.Total, aes(x=TotalClaims, y=..density..))+
  geom_histogram(color="blue", fill="light blue",stat="bin",binwidth = 25)+
  geom_density(color="dark blue",alpha=0.7)+
  geom_vline(aes(xintercept=mean(TotalClaims)), color="black", linetype="dashed")+
  labs(x="Total Claims",y="Density", title="P.m.f. of Homogeneous Poisson Process")+
  theme(plot.title = element_text(hjust=0.5))
dev.off()

  
#NON-HOMOGENEOUS POISSON PROCESS
#Total claims of each Simulations
nh.Sim.Total<-data.frame(colSums(nh.Sim))
colnames(nh.Sim.Total)<-"TotalClaims"

#Density of Total Claims in 1 year
png(filename = "Figures/Fig1.2.2.png",width=800,height=600,res=120)
ggplot(nh.Sim.Total, aes(x=TotalClaims, y=..density..))+
  geom_histogram(color="red", fill="light pink",stat="bin",binwidth = 20)+
  geom_density(color="darkred",alpha=0.7)+
  geom_vline(aes(xintercept=mean(TotalClaims)), color="black", linetype="dashed")+
  labs(x="Total Claims",y="Density", title="P.m.f. of Non-Homogeneous Poisson Process")+
  theme(plot.title = element_text(hjust=0.5))
dev.off()

#Task 1.3 Statistics for simulations
h.Sim.Summary<-t(apply(h.Sim,1,summary))
nh.Sim.Summary<-t(apply(nh.Sim,1,summary))
mean(h.Sim.Summary[4])
mean(nh.Sim.Summary[4])
mean(h.Sim.Total$TotalClaims)
mean(nh.Sim.Total$TotalClaims)


#Task 3: Provide Recommendations on Model Assumptions
#HOMOGENEOUS POISSON PROCESS
#Examine Distribution Fit
png(filename = "Figures/Fig2.1.1.png",width=800,height=600,res=120)
descdist(h.Sim.Total$TotalClaims,boot=1000)
dev.off()

#Normality Test
ad.test(h.Sim.Total$TotalClaims)
fitdistr(h.Sim.Total$TotalClaims,"normal")

#Fit distribution
h.fn<-fitdist(h.Sim.Total$TotalClaims,"norm")
h.fl<-fitdist(h.Sim.Total$TotalClaims,"lnorm")
h.fg<-fitdist(h.Sim.Total$TotalClaims,"gamma")

#Plot to Fit
png(filename = "Figures/Fig2.1.2.png",width=1500,height=600,res=120)
par(mfrow=c(1,3))
plot.legend<-c("Norm","LogNormal","Gamma")
denscomp(list(h.fn,h.fl,h.fg),legendtext=plot.legend)
qqcomp(list(h.fn,h.fl,h.fg),legendtext = plot.legend)
ppcomp(list(h.fn,h.fl,h.fg),legendtext = plot.legend)
dev.off()

#Test for goodness of fit
gofstat(list(h.fn,h.fl,h.fg),fitnames=c("Normal","Lognormal","Gamma"))

#NON-HOMOGENEOUS POISSON PROCESS
#Examine Distribution Fit
png(filename = "Figures/Fig2.2.1.png",width=800,height=600,res=120)
descdist(nh.Sim.Total$TotalClaims,boot=1000)
dev.off()

#Normality Test
ad.test(nh.Sim.Total$TotalClaims) 
fitdistr(nh.Sim.Total$TotalClaims,"normal")

#Fit distribution
nh.fn<-fitdist(nh.Sim.Total$TotalClaims,"norm")
nh.fl<-fitdist(nh.Sim.Total$TotalClaims,"lnorm")
nh.fg<-fitdist(nh.Sim.Total$TotalClaims,"gamma")

#Plot to Fit
png(filename = "Figures/Fig2.2.2.png",width=1500,height=600,res=120)
par(mfrow=c(1,3))
plot.legend<-c("Normal","LogNormal","Gamma")
denscomp(list(nh.fn,nh.fl,nh.fg),legendtext=plot.legend)
qqcomp(list(nh.fn,nh.fl,nh.fg),legendtext = plot.legend)
ppcomp(list(nh.fn,nh.fl,nh.fg),legendtext = plot.legend)
dev.off()

#Test for goodness of fit
gofstat(list(nh.fn,nh.fl,nh.fg),fitnames=c("Normal","Lognormal","Gamma"))
