import pandas as pd
import numpy as np
from pandas_profiling import ProfileReport
import matplotlib.pyplot as plt
import os


### Review
review = pd.read_csv(r'C:\Users\sean_\Documents\Code\Airbnb_Shanghai_data\reviews.csv')
review_df = pd.DataFrame(review)
print(review_df.head)
review_df['listing_id'] = np.array(review_df['listing_id'])
review_df['id'] = np.array(review_df['id'])
review_df['reviewer_id'] = np.array(review_df['reviewer_id'])

reviews_profilereport = ProfileReport(review_df, title = 'reviews_profilereport')
reviews_profilereport.to_file("reviews_profilereport.html")

review_df['date'].head

plt.figure(figsize=(20, 10))
review_df['date'].groupby(review_df['date']).count().plot(kind='bar')
plt.show()


### listings
listings_txt = open(r'C:\Users\sean_\Documents\Code\Airbnb_Shanghai_data\listings.csv','r+',encoding='utf-8',errors='ignore')
listings_string = listings_txt.read()  


for i in range(len(listings_string)):
    if  listings_string[i-1] == "\\" and listings_string[i] == "n" and listings_string[i+1].isdigit == False:
        listings_string[i-1] == "" and listings_string[i] == ""
with open(r'C:\Users\sean_\Documents\Code\Airbnb_Shanghai_data\listings_edited.csv','r+',errors='ignore') as listings_edited:
    listings_edited.write(listings_string)

listings = pd.read_csv(r'C:\Users\sean_\Documents\Code\Airbnb_Shanghai_data\listings_edited.csv', encoding_errors= 'ignore',encoding='utf-8')
listings_df = pd.DataFrame(listings)

listings_profilereport = ProfileReport(listings_df, title = 'listings_profilereport')
listings_profilereport.to_file("listings_profilereport.html")


listings[5]
listings.to_excel('a.xlsx')