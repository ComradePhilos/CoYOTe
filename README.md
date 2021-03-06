# CoYOT(e)
#### Control Your OverTimes (easily)
<p align="left">
  <img style="float:left" src="https://camo.githubusercontent.com/d03c7836440de6dbc9eac0ea3cadcc5094afe6a2/68747470733a2f2f646c2e64726f70626f7875736572636f6e74656e742e636f6d2f752f37363932333834332f6e65772e706e67" width=200>   
</p>  
This programme is a lightweight, open-source and userfriendly tool to keep an eye on overtimes at work. It calculates - based on attendance times the user entered - how many hours of working time the user accumulated and visualises the balance so that he always is up to date. If used consequently one can save precious free time and organize working time in a way that employees and bosses might profit from. 

### open source
CoYOT(e) is open source. That means you can use it freely and distribute it under the terms of GPLv3 and even change it to fit your demands. And of course you can also contribute to this project as a programmer, designer or as a user sending feedback. You can also take the source code to compile it on almost every computer and operating system you want - Thanks to Lazarus IDE and it's multi-platform components.

### what can it do?
<p>
<ul>
<li>  create and edit weeks in a grid view</li>
<li> 	edit single entries in the grid like you would e.g. in Excel </li>
<li>  calculate your overall working time by entering begin and leave of a workday </li>
<li>  get to know how many hours you can take off based on overtimes </li> 
<li>  manage and calculate the number of days you took off </li>
<li>  load and save to/from a file or upload to a database server ( in future )</li>
<li>  change the color theme </li>
</ul>
</p>

<img style="float:left" src="https://camo.githubusercontent.com/cbbf2c1edd2d710605b376abdb9121b6ec7e5838/68747470733a2f2f646c2e64726f70626f7875736572636f6e74656e742e636f6d2f752f37363932333834332f53637265656e73686f742532302d25323031342e30362e323031342532302d2532303232253341313525334133302e706e67">

<img style="float:left" src="https://camo.githubusercontent.com/a6fd91bb65acfd2735e9546ff6823ec62b903472/68747470733a2f2f646c2e64726f70626f7875736572636f6e74656e742e636f6d2f752f37363932333834332f626572756673736368756c652e706e67">

### what is planned in future?
<p>
<ul>
<li>  track time for a number of people and easily switch between them </li>
<li>  releases for Windows, MacOS and Linux </li>
<li>  language support for multiple languages ( currently english only ) </li>
<li>  statistics, bar charts or graph charts </li>
<li>  export functions e.g. to various file formats </li>
<li>  upload to and download from a firebird database </li> 
</ul>
</p>

### downloads
You will find any older version by clicking the link to the <a href="https://github.com/ComradePhilos/CoYOTe/releases">Download Page</a>. Read the release notes carefully! Alternatively you can of course always download the newest commit of the programme on this main page ( click "<a href="https://github.com/ComradePhilos/CoYOTe/archive/master.zip">download zip</a>" on the right ), if you are fine with the fact that the version might look and feel like it is not yet finished and many functions/buttons etc. may have no effect or even may cause errors and crashes.

### installation
<p>
<ul>
<li>1.	download the current package</li>
<li>2.	unzip it to any destination you want</li>
<li>3.	open the /bin folder</li>
<li>4.	double click on the binary that is for your OS</li>
<ul>  
  <li>  CoYOTe-darwin for MacOS</li>
  <li>  CoYOTe-linux for Linux</li>
  <li>  CoYOTe-win.exe for Windows</li>
</ul>
</ul>
</p>


There is no installation tool needed and the programme won't create any files to another directory, so that the programme is always portable. That means, that you can easily copy the programme folder to another computer and use it there without installation needed. If there is no binary for your OS check out the last paragraph "compile or edit the project", where you can find information on how to compile the project. Note that the programme is still in development and so the programme folder may contain files that would not be needed in a normal release version.

### compile or edit the project
#### via Lazarus IDE GUI
The programme is written in Object Pascal and created with Lazarus IDE and the Free Pascal Compiler. To open/edit the project you can open the "coyote.lpi"-file with the <a href="http://www.lazarus.freepascal.org/">Lazarus IDE</a> 
and start coding/compiling! If you compile CoYOT(e) on a system, that is supported by the Free Pascal Compiler, you will get a binary file matching your system in the "bin"-folder. 

#### via command prompt
```bash
git clone https://github.com/ComradePhilos/coyote.git
cd coyote
lazbuild -B CoYOTe.lpi
```