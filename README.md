# Computational 3D Imaging with Position Sensors
Code and data for "Computational 3D Imaging with Position Sensors" in ICCV 2023.

## Code
We include a physically-accurate two-bounce rendered implemented in MATLAB in `two_bounce/`.
`macro_scan.m` demonstrates how to perform a 3D line scan of an object using with and without global illumination suppression.
`macro_nPatt_v_sc.m` demonstrates how to sweep the number of patterns and pattern scale.

## Data
3D point clouds from our lab prototype are in `point_clouds` as .ply files. They can be viewed in MeshLab.

`-no-suppression` denotes a single raster scan was used.

`-minmax` denotes the min/max processing of Nayar et al. [1] was used for global illumination suppression.

`-ours` denotes our proposed regression method was used for global illumination suppression.

Each point cloud is post-processed with bilateral filtering on the depth map, and points whose total intensity is below a threshold are removed.

## [Paper](http://imagesci.ece.cmu.edu/files/paper/2023/PSD_ICCV23.pdf)

## [Supplemental](http://imagesci.ece.cmu.edu/files/paper/2023/PSD_ICCV23-Supp.pdf)

## Citation
```
@inproceedings{klotz2023psd3d,
 author = {Klotz, Jeremy and Gupta, Mohit and Sankaranarayanan, Aswin C.},
 title = {Computational 3D Imaging with Position Detectors},
 booktitle = {IEEE Intl. Conf. Computer Vision (ICCV)},
 year = {2023},
}
```

## References
[1]: S. K. Nayar, G. Krishnan, M. D. Grossberg, and R. Raskar. Fast separation of direct and global components of a scene using high frequency illumination. In ACM Transactions on Graphics, volume 25, pages 935–944. 2006