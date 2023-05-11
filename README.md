<p align="center">
  <img width="281" alt="image" src="https://github.com/carlosasmartins/trimark/assets/6072464/42323843-e4c1-4c1e-ba91-275f4ff70ef1">
</p>

# Trimark
A simple enough application that just trims one video!

### 🤨 What does it do?
- Trims one video.
- Displays a watermarking using Metal driven rendering.
- Adjustable playback window by draggable trimming controls.
- Seeking controls on the thumbnail previews.
- Export and share videos that were trimmed!
- _A lot of attention to interactions to avoid weird scenarios_

### 🤔 Show me some pictures!
![Untitled-2](https://github.com/carlosasmartins/trimark/assets/6072464/aa540ef3-567d-4fbd-9bc0-41d231e1db23)


### 🧐 I'm not convinced, do you have a video?

https://github.com/carlosasmartins/trimark/assets/6072464/57957e80-f674-40f5-878c-1ce8d7304335

### How about that code, how do I navigate it?

It alls starts at `AppDelegate`.

Then a `Home` scene is instantiated by usage of a `AppCoordinator`.
In that `Home` you have a `Home+ViewController` and a `Home+ViewModel`.
The `ViewModel` is very simplified _(a lot more could be on it)_.

You also have some components.
A `VideoPlayer` abstracting away playback logic, listening to events...
  The `VideoPlayer` also has some tools like a `ThumbnailGenerator` and a `VideoExporter`. It also has `Watermarking` logic.
A `TrimmingView` that contains all the UI related to controlling the playback edges, scrubbing in the UI...

And you also have some unit tests.
