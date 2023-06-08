
###RFM Analysis using Stata

bysort CustomerName: egen last_purchase = max(OrderDate)

format last_purchase %td

sort CustomerName OrderDate

list CustomerName OrderDate OrderID last_purchase in 1/100,sepby(OrderDate)

bysort CustomerName: generate y = _n == 1

bysort CustomerName: gen recency =(td(31dec2014)+1 - last_purchase) if y==1

sort CustomerName OrderDate

list CustomerName CustomerID OrderDate last_purchase recency in 1/100, sepby(CustomerName)

bysort CustomerName (OrderDate): generate time = OrderDate - OrderDate[_n-1]

sort CustomerName OrderDate

list CustomerName OrderID OrderDate time in 1/50, sepby(CustomerName OrderID)

bysort CustomerName: egen frequency = mean(time) if time!=0

replace frequency=. if y!=1

sort CustomerName OrderDate

list CustomerName OrderDate time frequency y in 1/100, sepby(CustomerName)

drop y

bysort CustomerName OrderDate: generate y = _n == 1

sort CustomerName OrderDate

list CustomerName OrderID OrderDate time Sales y in 1/100,sepby(CustomerID OrderID)

bysort CustomerName: egen frequency2 = sum(y)

sort CustomerName OrderDate

list CustomerName OrderID OrderDate frequency frequency2 y in 1/100,sepby(CustomerID OrderID)

replace frequency2=. if missing(frequency)

sort CustomerName OrderDate

list CustomerName OrderID OrderDate frequency frequency2 y in 1/100,sepby(CustomerID OrderID)

summ frequency2,detail

summ frequency2 if y==1,detail

codebook CustomerName

drop y

bysort CustomerName (OrderDate): gen age=OrderDate[_N]-OrderDate[1]+1

sort CustomerName OrderDate

list CustomerName OrderID OrderDate frequency frequency2 age in 1/100,sepby(CustomerID OrderID)

replace age=. if missing(frequency)

gen invoice_my=ym(year(OrderDate),month(OrderDate))

bysort CustomerName (invoice_my): gen age_months=invoice_my[_N]-invoice_my[1]+1

replace age_month=. if missing(frequency)

bysort OrderID: egen purchase_amt = sum(Sales)

sort OrderDate CustomerName

list CustomerName OrderDate OrderID Sales purchase_amt in 1/25,sepby(CustomerName OrderID)

bysort OrderID: generate y = _n == 1

sort CustomerID OrderDate

list CustomerName OrderDate OrderID Sales purchase_amt in 1/25,sepby(CustomerName OrderID)

bysort CustomerName: egen monetary = mean(purchase_amt) if y==1

bysort CustomerName (monetary): generate dup =cond(_N==1,0,_n)

sort CustomerName OrderDate

list CustomerName OrderDate OrderID Sales purchase_amt monetary dup in 1/200,sepby(CustomerName OrderID)

replace monetary=. if dup!=1

drop dup y

sort CustomerName OrderDate

list CustomerName OrderDate OrderID Sales purchase_amt monetary in 1/200,sepby(CustomerName OrderID)

summ monetary,detail

bysort OrderID: generate y = _n == 1

bysort CustomerName: egen monetary2 = sum(purchase_amt) if y==1

bysort CustomerName (monetary2): generate dup =cond(_N==1,0,_n)

replace monetary2=. if dup!=1

drop dup y

summ monetary2,detail

*************************RANKING*******************************

collapse (mean) recency (mean) frequency (mean) frequency2 (mean) monetary (mean) monetary2 (mean) age (mean) age_month,by(CustomerName)

tabstat recency, stats(mean min max)

xtile rank = recency, nq(5)

tab rank

table rank,statistic(min recency) statistic(max recency) statistic(mean recency) statistic(n recency) nototal

gen R=5 if rank==1
replace R=4 if rank==2
replace R=3 if rank==3
replace R=2 if rank==4
replace R=1 if rank==5

table (var) (R),statistic(min recency) statistic(max recency) statistic(n recency) nototal

table R,statistic(min recency) statistic(max recency) statistic(n recency) nototal

tabstat frequency, stats(mean min max)

drop rank

xtile rank = frequency, nq(5)

tab rank

table rank,statistic(min frequency) statistic(max frequency) statistic(n frequency) nototal

gen F=5 if rank==1
replace F=4 if rank==2
replace F=3 if rank==3
replace F=2 if rank==4
replace F=1 if rank==5

table F,statistic(min frequency) statistic(max frequency) statistic(n frequency) nototal

drop rank

xtile rank = frequency2, nq(5)

tab rank

table rank,statistic(min frequency2) statistic(max frequency2) statistic(n frequency2) nototal

gen F2=rank

drop rank

xtile rank = monetary, nq(5)

tab rank

table rank,statistic(min monetary) statistic(max monetary) statistic(n monetary) nototal

gen M = rank

drop rank

xtile rank = monetary2, nq(5)

tab rank

table rank,statistic(min monetary2) statistic(max monetary2) statistic(n monetary2) nototal

gen M2 = rank

drop rank

gen RFM = real(string(R) + string(F) + string(M))

summ RFM

count if RFM==555

count if RFM==111



























