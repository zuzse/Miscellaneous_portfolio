## **SQL Covid project**

In this project I used publicly available data set on Covid to showcase different SQL queries. 
I am performing data exploration on covid cases within European countries as well as comparison of Scandinavia (as I currently live in Sweden) with Visegrad roup (as I come from Slovakia).
The aim was to show usage of JOINS, CTEs, Nested queries and Temporary tables and thus, the analysis doesn’t tell a specific story :-) 


## **Lambda**

Lambda by day is a real case project in which I aimed to explore daily changes in lambda (see below).

During my PhD I was working with nematode worms (tiny little worms which, if not inhabiting petri dishes in molecular or evolutionarily focused labs, freely live in soil). I was studying a change in reproduction based on temperature in which we cultivate them (or quite technical reasons, the reproduction schedule differs based on what temperature worms live in). 
 
 One way how to calculate reproduction is to simply sum up all the offspring they have throughout their life (Total/Life time reproduction). This measure however doesn’t tell us much on how big impact one specific worm will have on the whole population.

Imagine, once you hit your forties, you get 2 kids and each of your kids will also get two kids later on in their life. Your friend also gets two kids, but unlike you, already in her twenties. At the age of 40 she already gets 2 grandkids from each of her kids. This means, that by your age of 40, from all the world population, 2 people are your descendants (caring your genes) while it is 6 people for your friend. Therefore, without any changes in children number, just by altering age in which you get them, you can alter how much you contributed to the whole population. It is the same for worms. 
 
Therefore, depending on the question, you want to answer, then to look on total number of offspring, it might be a better idea to take into account also timing of the reproduction. And such a measure, which considers both, timing and a number of the offspring, is called **LAMBDA**. Lambda thus puts the highest value on an early reproduction.

Because a value and also a number of offspring which worms have is decreasing by an age, small amount of offspring late in life, will have no more impact on lambda. However, it will still have a huge impact on my working schedule and wellbeing (as I have to show up in the lab and record this non-significant offspring). That’s because the standard way we calculate lambda is to go to the lab every single day and check individually each (tens or hundreds) of worms until their either die, or stop reproducing. But because, as explained above, small number of the late offspring will not change the lambda value there must be a threshold until when is it still worth it to record reproduction of worms, and after what the lambda will not change (and I can as well stay at home - or start a new experiment :-/). 

Thus, in this script, I calculated, from real data the threshold day, after which checking worms for reproduction has little sense as it adds little or nothing to the Lambda value.
And, as mentioned above, because reproductive schedule depends on a temperature, I did those calculations separately for worms grown in 20⁰C and 25⁰C (the temperatures we commonly use in the lab). Unfortunately, there are some technicalities (excluding matricidal worms: matricide = internal hatching of offspring inside of the mother) which I am not explaining in detail in the script.  
