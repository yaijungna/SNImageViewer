SNImageViewer
=============

Screenshots
===========
<img src="https://raw.githubusercontent.com/NarekSafaryan/SNImageViewer/master/SNImageViewerDemo/screenshot.png" width=320>
<img src="https://raw.githubusercontent.com/NarekSafaryan/SNImageViewer/master/SNImageViewerDemo/SNImageViewer.gif" alt="SNImageViewer Screenshot" width="320" height="568" />

How to use
===========

1.Import SNImageViewer.h     																				
2.Implement SNImageViewerDatasource methods:

	1)- (NSInteger)numberOfImagesInImageViewer:(SNImageViewerController *)imageViewer
	2)One of two optional methods in the datasource
	  For web images
	  - (NSURL *)imageViewer:(SNImageViewerController *)imageViewer imageUrlAtIndex:(NSInteger)imageIndex;
	  or for local images
	  - (UIImage *)imageViewer:(SNImageViewerController *)imageViewer imageAtIndex:(NSInteger)imageIndex;

3.And write this on your action method

	SNImageViewerController *imageViewerController = [[SNImageViewerController alloc] init];
	imageViewerController.datasource = self;
	imageViewerController.delegate = self;
	[_imageView setupImageViewer:imageViewerController]; 

Licence
===========

The MIT License (MIT)

Copyright (c) 2014 Narek Safaryan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
