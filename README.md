# Automated Signature Verification of CEDAR using the Tangent Space and the SPD Riemannian Manifold in MATLAB

This project aims at capturing the fidelity presented by the schematic of the use of the logarithmic mapping: an intuitive form of subtraction between two points in the SPD Riemannian Manifold.

![image](https://github.com/user-attachments/assets/0072b669-ffbf-4875-a132-91bc2c6b328d)

_Illustration of the y vector pointing in the direction of point Y while located in the X's Tangent Space. 
At the same time, the geodesic that is non-lineary connecting the two points of the Manifold is also depicted. 
The dotted line marks the transformation of the base of Y to the coordinate system of the X's Tangent Space._

# Project Structure

- _**conv2vec_with_logm.m**_: Contains functions or scripts related to converting data with logarithmic mapping.
- _**OmegaMinusFormation.m**_: Handles the formation of Omega Minus matrices.
- _**OmegaPlusFormation.m**_: Handles the formation of Omega Plus matrices.
- _**RefsQuestionNV.m**_: Contains references or questions related to NV.
- _**Second_senario.m**_: Implements the second scenario for a specific experiment or simulation.
- _**Train_Val_Split.m**_: Splits data into training and validation sets.
- _**VecCell.m**_: Manages vector cells.
- _**VecsOfTangentPlaneNV.m**_: Handles vectors of the tangent plane for NV.

# Pseudocodes

- For the Second_scenario.m

![image](https://github.com/user-attachments/assets/e15fe7a9-0372-4f1a-9ef8-46b7ca0f3353)

- For the Train_Val_Split.m

![image](https://github.com/user-attachments/assets/ad13ff7d-a6f3-403c-a4da-1f9d4035302c)

- For the OmegaPlusFormation.m

![image](https://github.com/user-attachments/assets/06572e26-9a6b-4a56-b38e-7b30ac06e3cc)


- For the OmegaMinusFormation.m

![image](https://github.com/user-attachments/assets/560e3769-582a-420b-9921-d7cf80855e77)


- For the RefsQuestionNV.m

![image](https://github.com/user-attachments/assets/a394deed-ba15-4652-a2f4-7884e50f8afd)


# Results

| Iteration | Fold 1 | Fold 2 |
|-----------|--------|--------|
| 1         | 1.1011 | 2.2531 |
| 2         | 1.1607 | 0.0463 | 
| 3         | 0.3720 | 1.4969 |
| 4         | 4.7024 | 0.1389 | 
| 5         | 0.2827 | 1.8827 | 

***Mean EER = 1.3437***
