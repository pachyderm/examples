# Streamlit Image Gallery 
This example shows how to deploy a Streamlit application in a Pachyderm Service Pipeline. The benefit of this is, every time your data changes, the Streamlit application will restart, showing you the application based on the most recent version of your data. 

In this example, we'll use a Streamlit Image Gallery to show all the images in our pipeline. 

## TLDR;

```bash 
pachctl create repo images
pachctl put file images@master:liberty.png -f http://imgur.com/46Q8nDz.png
pachctl create pipeline -f pachyderm/streamlit.json

pachctl put file images@master:AT-AT.png -f http://imgur.com/8MN9Kg0.png

pachctl put file images@master:kitten.png -f http://imgur.com/g2QnNqa.png
```