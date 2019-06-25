# Reliability of Inverters
  
This project aims to model the efficiency and the reliability of inverters.  

In terms of reliability, only the IGBT inverter in BMW i3 and the Cascaded H-bridge inverter are modelled. The metric for reliability is the expected mileage until break down. The SiC MOSFET inverter is not modelled, due to the lack of reliability data for these new switches. This model is not published in any paper yet, but the comments should be sufficient to explain the sources and the deriviation of the model.

However, these models are specific to the switches and inverters. The author cannot guaranty the validy and the accuracy of the model still hold, when trying to extra-polate or reshape the map.

## Getting Started
As long as MATLAB is installed, downloading the model is sufficient for the usage.
  
### Prerequisites
As the models are programmed in MATLAB 2017b, necessary licenses of MATLAB are required. There is no more dependencies other than that.
  
### How to use
Here explanations regarding how to the two tool are provided

### Obtain Reliability
  
In order to evaluate the reliability of the CHB and the IGBT inverter, the user is referred to the Reliability folder, and follow the steps below:

#### Step1: 
Open the Reliability folder in the downloaded repository

#### Step2: 
Open the file Main_Rainflow_Reliability.m in MATLAB

#### Step3: 
Select the driving cycle to simulate, by copying the commented option in line 8, and set this value to Driving_Cycle_Name 

#### Step4: 
Select the inverter to simulate, by setting the Inverter_Type to be 'IGBT' or 'CHB'

#### Step5: 
Run the file, and the results will be display in the console of MATLAB

#### Additional Information:
Additionally, necessary models are put in folder Reliability/functions. The paper based on which the model is built is put in the comment as well for the interested users. For the reliability of the CHB inverter. The assumptions regarding the Rth_PCB_Junction should be reconsidered carefully. Right now, this value is assumed differently in different driving cycles, due to different transient characteristics of the junction temperature in different driving cycles. The the assumptions are rather pessimistic, in order to demonstrate the worst case for the CHB. The reliability model is not verified, as it is impossible to verify the reliability with limited time and cost.

Data folder contains the temperature curves and electric stress curves of the switches
Function folder contains the reliability models of different components. The sources of these models are stated in the comments for the user to check
  

## Deployment
* [Matlab R2017b](https://de.mathworks.com/products/matlab.html) 
  
## Versioning
First version
  
## Authors
Fengqi Chang
  
## License
This project is licensed under the LGPL License - see the LICENSE.md file for details
