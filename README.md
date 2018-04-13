# rpygo-notebook

rpygo-notebook is a dockerized Jupyter notebook that allows you to run Python 3, R, and Go code within the Jupyter notebook interface.

rpygo-notebook has three variants:
- [minimal](#minimal-container) - Just run R, Python3 and Go in Jupyter notebook
- [data-science](#data-science-container) - minimal + preinstalled data science Python packages
- [tensorflow](#tensorflow-container) - data-science + TensorFlow in Python and Go, and computer vision libraries

All versions has [Jupyter] notebook installed, and can run Python 3, R (using [IRKernel]), and Golang (using [gophernotes]) within the notebook interface.

Note that not all Golang syntax works within the notebook.
The biggest things missing are support for unexported struct fields and interfaces.
The complete list of limitations can be found at https://github.com/gopherdata/gophernotes#limitations

## Minimal container

The minimal version has `ipython` and `jupyter` Python packages installed,
as well as other packages required to run Jupyter notebook.

Download the container using the following command

	docker pull kentwait/rpygo-notebook


## Data science container

The data science version adds the following prebuilt Python libraries:
- numpy - scientific computing
- scipy - scientific computing
- matplotlib - plotting
- seaborn - high-level plotting
- bokeh - interactive plotting
- pandas - dataframes
- numba - code optimization
- statsmodels - statistical programming
- scikit-learn - machine learning tools
- networkx - graph structures

Download the container using the following command

	docker pull kentwait/rpygo-datascience-notebook


## Tensorflow container

The tensorflow version is built on top of the data science container adds the following:
- tensorflow in Python
- tensorflow in Go

Additional Python libraries
- scikit-image - computer vision
- pillow (PIL) - image manipulation
- opencv - computer vision
- dlib - computer vision and machine learning

Download the container using the following command

	docker pull kentwait/rpygo-tensorflow-notebook

## Adding third-party libraries

Third-party libraries for Python, R, and Go can be added by adding it within the container and commiting the change.

Another method is to place additional Python, R, and Go libraries into Python, R, and Go custom library folders respectively. Then, bind-mount these custom library folders to the following volume endpoints
- Python: `/root/python`
- R: `/root/r`
- Go: `/root/go`

For example, additional Python 3.6 libraries placed in `/path/to/custom/python` can be added by bind-mounting to `/root/python`:

	docker run -it \
	-v /Users/kent/notebooks/:/notebooks/ \
	-v /path/to/custom/python:/root/python \
	-p 8887:8888 \
	kentwait/rpygo-datascience-notebook


[Jupyter]: http://jupyter.org
[IRKernel]: https://github.com/IRkernel/IRkernel
[gophernotes]: https://github.com/gopherdata/gophernotes
