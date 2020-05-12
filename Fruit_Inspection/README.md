# Fruit Inspection 

In this project I explore a tiny part of the **image analysis** world using a fruit as subject. 
The aim is to locate imperfections on some fruit images and the workflow is the following:
  1. **Load Images**
  2. **Fruit Segmentation**
  3. **Defects Detection**
  4. **Draw Imperfections**
 
## Data
We have three pairs of images acquired through a NIR (Near Infra-Red) and a color camera with a little parallax effect.

The images are kindly provided by [UNITEC S.p.a.](http://www.unitec-group.com/) and they are part of the dataset used in the course [91254 - Image Processing and Computer Vision - University of Bologna](https://www.unibo.it/en/teaching/course-unit-catalogue/course-unit/2019/446598).*

## Results
The **image segmentation** is performed by using the *Otsu's method* and the imperfections are detected by the *Canny Edge Detector*.

Here are the resulting images, refined by applying the **erosion operation**.
![Results](https://github.com/EleMisi/TinyProjects/blob/master/Fruit_Inspection/images/Results.png)
### Built With

* [Python 3.7](https://www.python.org/downloads/release/python-370/)


### Author

* [EleMisi](https://github.com/EleMisi)


### License

This project is licensed under the Apache License 2.0 - see the [LICENSE.md](https://github.com/EleMisi/TinyProjects/blob/master/LICENSE) file for details.

### External links
* Fruit Inspection project on my [website](https://eleonoramisino.altervista.org/fruit-inspection/).



