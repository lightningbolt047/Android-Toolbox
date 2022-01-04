<br/>
<div align="center">
    <img src="readme_assets/lightningBoltLogo.png" alt="logo" width="150" height="150"/>
    <h1>Android-Toolbox</h1>
</div>

![Downloads](https://img.shields.io/github/downloads/lightningbolt047/Android-Toolbox/total) ![Watchers](https://img.shields.io/github/watchers/lightningbolt047/Android-Toolbox?label=Watch) ![Stars](https://img.shields.io/github/stars/lightningbolt047/Android-Toolbox?style=social) ![License](https://img.shields.io/github/license/lightningbolt047/Android-Toolbox)

<div>
    <h2>About</h2>
    <p>This application is built with Flutter. It uses adb behind the scenes to execute each and every user operation. The application comes bundled with adb, so you need not have adb installed and configured in path. I plan to bring it to linux after adding some functionality.</p>
</div>

<div>
    <h2>What does it do?</h2>
    <p>As of now, you can use it to access your internal storage either on your phone or on WSA. I plan to add more functionality in the coming days.</p>
    <h2>Okay I'm interested. How do I install it?</h2>
    <p>As of now only the Windows installer is available (Although I plan to release it on linux and macOS (if I can get my hands on a Mac)). You may download it from this repo's releases which you can find here <a>https://github.com/lightningbolt047/Android-Toolbox/releases</a>.</p>
    <h2>Do I have to keep checking this repo for future updates to the app?</h2>
    <p>No you don't! The app will notify you when there is an update available, and you may choose to download and install the update from within the app.</p>
    <h2>Feature X is awesome, I can't wait to try it out, but it is a prerelease. How do I try it out?</h2>
    <p>There is support for updating to prerelease builds from within the app. Beware! Prerelease builds might not work as intended, and may even break updates (which might happen if I screw with the updater) in which case you will have to manually install the next update.</p>
</div>

<div>
    <h2>Clone and build it yourself</h2>
    <ul>
        <li>
            Make sure you have the Flutter SDK installed. You may check this by running <code>flutter doctor</code>.
        </li>
        <li>
            Clone this repo: <code>git clone https://github.com/lightningbolt047/Android-Toolbox.git</code>.
        </li>
        <li>
            Fetch the dependencies using <code>flutter pub get</code>
        </li>
        <li>
            Build a release build: <code>flutter build [platform_name] --release</code>
        </li>
    </ul>
</div>