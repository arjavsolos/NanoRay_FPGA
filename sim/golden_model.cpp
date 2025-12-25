#include <iostream>
#include <fstream>
#include <cmath>
#include <vector>
#include <cstdint>

// Q16.16 fixed point representation
typedef int32_t fixed_t;
const int32_t ONE = 65536; // 1 << 16

int main() {
    const int W = 640;
    const int H = 480;
    std::ofstream img("output.ppm");
    img << "P3\n" << W << " " << H << "\n255\n";

    // Sphere at (0, 0, 50) with Radius 20
    int32_t sphere_z = 50 * ONE;
    int32_t radius_sq = 20 * 20 * ONE; 

    for (int y = 0; y < H; y++) {
        for (int x = 0; x < W; x++) {
            
            int32_t ray_x = (x - W/2) * (ONE / 10); 
            int32_t ray_y = (H/2 - y) * (ONE / 10);
            int32_t ray_z = ONE; // Forward direction

            // Ray-Sphere Intersection: t^2(D.D) + 2t(O.D) + (O.O - R^2) = 0
            // Simplified for O=(0,0,0): intersect if (ray_x^2 + ray_y^2) < radius^2 (roughly)
            // Model in rtl will do real work, here we just check distance squared
            
            long long dist_sq = ((long long)ray_x * ray_x + (long long)ray_y * ray_y) >> 16;
            
            if (dist_sq < radius_sq) {
                img << "255 0 0\n"; // Red Pixel (Hit)
            } else {
                img << "0 0 0\n";   // Black Pixel (Miss)
            }
        }
    }
    std::cout << "Image generated: output.ppm" << std::endl;
    return 0;
}