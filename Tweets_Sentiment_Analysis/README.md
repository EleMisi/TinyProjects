# Sentiment Analysis on Tweets

As part of [Data Mining, Text Mining and Big Data Analytics exam](https://www.unibo.it/en/teaching/course-unit-catalogue/course-unit/2020/446610), I performed a sentiment analysis on a large supervised dataset of tweets ([Sentiment140 dataset](https://www.kaggle.com/kazanova/sentiment140)). 

The project is focused on **exploring 3 text representation strategies**:
* *Bag-of-Words* (BoW)
* *TF-IDF* 
* *Word2Vec* (w2v) 

and **comparing 3 classifiers**:
* *Multinomial Naive Bayes* (MNB)
* *Logistic Regression* (LogReg)
* *Multi-layer Perceptron* (MLP)
_________________________
**Project workflow**


1.   *Download Data*
2.   *Exploratory Data Analysis*
3.   *Tweets Features Extraction*
4.   *Text Preprocessing*
5.   *Models Training*
6.   *Models Comparison* 


(Please refer to the [notebook](https://github.com/EleMisi/TinyProjects/blob/master/Tweets_Sentiment_Analysis/tweets_sentiment_analysis.ipynb) for a more detailed description.)
_________________________

## How to Run
> Download the [notebook](https://github.com/EleMisi/TinyProjects/blob/master/Tweets_Sentiment_Analysis/tweets_sentiment_analysis.ipynb) and run locally with [Jupyter](https://jupyter.org/)  
 
or  

> [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/1rMkiqWoQvKZJAD4D2TqZTLexob6csivd?usp=sharing)

## Models Training
I fine-tuned and trained 16 different combinations of text pre-processing, text representation and classifier.
All the information about models configurations and training are reported in the notebook.

## Results
Here are the models accuracy on test set (please refer to section *Models Comparison* of the notebook for more details).
![image](https://user-images.githubusercontent.com/33552669/114263696-725b1900-99e7-11eb-9fdd-12299069beb3.png)
![image](https://user-images.githubusercontent.com/33552669/114263707-79822700-99e7-11eb-852b-5c813982fd14.png)

______________________

### Built With

* [Python 3.7](https://www.python.org/downloads/release/python-370/)


### Author

* [EleMisi](https://github.com/EleMisi)


### License

This project is licensed under the Apache License 2.0 - see the [LICENSE.md](https://github.com/EleMisi/TinyProjects/blob/master/LICENSE) file for details.

### External links
* Read more about this project on my [website](https://eleonoramisino.altervista.org/sentiment-analysis-on-tweets/).
