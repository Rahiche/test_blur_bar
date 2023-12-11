







| ![Simulator Screenshot - iPhone 14 Pro - 2023-12-11 at 19 52 26](https://github.com/Rahiche/test_blur_bar/assets/37366956/76d09018-dccf-4cfd-97b4-cd82bc57afe5) | ![Simulator Screenshot - iPhone 14 Pro - 2023-12-11 at 19 52 23](https://github.com/Rahiche/test_blur_bar/assets/37366956/3543497e-973c-4bd6-a3b1-03919e90beaa) | ![Simulator Screenshot - iPhone 14 Pro - 2023-12-11 at 19 52 19](https://github.com/Rahiche/test_blur_bar/assets/37366956/fbfb67b1-13f0-4980-86e8-61553661487a) | ![Simulator Screenshot - iPhone 14 Pro - 2023-12-11 at 19 52 16](https://github.com/Rahiche/test_blur_bar/assets/37366956/6b3bb3cd-ee02-48df-a7c0-d987d16ae894) |
|---|---|---|---|


## *More Context About This Experiment*:

Flutter offers blur effects through two widgets: **ImageFiltered** and **BackdropFilter**. Both use the same algorithm behind the scenes (`ImageFilter.blur`), known as **Gaussian blur**. Like other frameworks, Gaussian blur is preferred as the default choice because it **looks natural (smooth and pleasing)** and is **efficient (fast up to a certain point).**

In Flutter, **we can only use the packaged Gaussian blur,** but there are other types of blurs out there, like the more naturally looking lens blur and algorithmically faster blurs like the box blur.

### Reason 1: I Want More Flexibility

On the other hand, while Gaussian blur is efficient, it doesn't scale well beyond a certain threshold.

![image](https://github.com/Rahiche/test_blur_bar/assets/37366956/8602d4bf-d29e-43e3-b521-b4b3adb80e38)

https://www.intel.com/content/www/us/en/developer/articles/technical/an-investigation-of-fast-real-time-gpu-based-image-blur-algorithms.html

There are open issues in Flutter, and based on the GitHub notifications I'm receiving, the team is already working a lot on the performance of the blur recently. However, they are still using Gaussian blur, and as shown in the above comparison, even with improvements, there will always be something better, though perhaps less natural.

### Reason 2: I Want Faster Blur

With this small example:
I was able to observe different types of blurs, and some of them still look and perform well.
It's not faster (mainly because of the overhead of having two lists and applying the effect to the entire list, plus clipping afterward).

There is a **clipFirst** flag where, if enabled, it should technically be faster because we are not applying the blur to the entire surface and then clipping the content. Instead, we do the reverse, which is better because it sends fewer pixel data to the shader for processing.

If you check the demo on Chrome, you will see only the first blur working (shaders code not working?), but for better testing, check it on iOS:
https://test_blur.codemagic.app/








