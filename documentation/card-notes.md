# card and scene notes.

The goal of the game is to win. The way to win is to raise a child to 18 years of age without running out of money.

There are 19 scenes. Each scene is one year of the child's life.
The chapter zero (the prelude) is the pregnancy, so 18 scenes, with 1 year of pregnancy (rounded up) and 18 years of life.

In each scene there is 1 major challenge, 2 medium challenges, and 4 common challenges.
Each challenge-turn you see 1-3 chalenges and pick one.
When you survive each challenge, you get money, and a choice of 1 of 3 benefits.
The order of the challenges is always as follows:
Major, Common, Medium, Common, Medium, Common, Common.
So for your first turn, you will see a Medium challenge and two common challenges.
If you beat the medium challenge, you see three common.

To beat the challenge, you use your benefits. By default, you start with 10 benefits and draw 5 of them as your default empathy is 5.
Benefits have a cost (money), and a status update (increments or decrements a status)
Benefits are Legendary, Rare, Uncommon, and Common
When you beat a challenge you get to pick one of three benefits.

| Challenge Rarity | Card Rarity 1 | Card Rarity 2 | Card Rarity 3 |
|------------------|---------------|---------------|---------------|
| Major            | Legendary     | Rare          | Uncommon      |
| Medium           | Rare          | Uncommon      | Common        |
| Common           | Uncommon      | Common        | Common        |

This ddocument outlines the scenes, challenges, and benefits.

## scene 0, pregnancy.

### statuses

statuses cannot go below zero or above 9999

| ID | Name    | Description                                | Default Value |
|----|---------|--------------------------------------------|---------------|
| 1  | Empathy | Number of cards drawn each turn in a fight | 5             |
| 2  | Money   | If it goes to zero you lose.               | 5000          |

### challenges
| ID | Rarity | Name              | Description                                                | Status    | Cost |
|----|--------|-------------------|------------------------------------------------------------|-----------|------|
| 1  | Major  | Its Here          | The baby is ready to be born.                              | Medical+1 | 2000 |
| 2  | Medium | Morning Sickness  | You feel sick, maybe theres a problem with the baby.       | Medical+1 |  200 |
| 3  | Medium | No Good Boyfriend | He got mad, took the money, and left.                      |           |  200 |
| 4  | Common | Market Day        | Its time to buy no food, with no money.                    |           |   50 |
| 5  | Common | Gambling          | If theres no risk, theres no reward.                       |           |   50 |
| 6  | Common | Beauty Contest    | Everyone wants to see beautiful people.                    |           |   50 |
| 7  | Common | New Crypto        | Magic internet money, much more stable than regular money. |           |   50 |


### benefits
| ID | Rarity      | Name               | Description                                                      | Status That is Updated | Status Difference |
|----|-------------|--------------------|------------------------------------------------------------------|------------------------|-------------------|
| 1  | Legendary   | Foreign Investment | If you can convince a foreigner to invest, anything is possible. | Cost,Empathy           | 1000, -1          |
| 2  | Rare        | Health Insurance   | If challenge has 1 medical, reduce challenge cost by 2000        | Medical,Cost           | 0,-2000           |
| 3  | Uncommon    | Actual Good Job    | You have an actual good job.                                     | Cost                   | -10               |
| 4  | Common      | So Many Captchas   | You can make money doing captchas, but its not a lot.            | Cost                   | -1                |
| 5  | Common      | Phone a friend     | Borrow money from a friend.                                      | Cost,Empathy           | -5,-1             |
| 6  | Common      | Paid you back      | Pay back money to a friend.                                      | Cost,Empathy           | +5,+1             |
