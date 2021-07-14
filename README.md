# MessageInputBar

## What is it?

`MessageInputBar` is a simple text input bar implemented in modularized way, you can add any element you want to the bar at two types of location. 

It provides some basic features like following:

* Decouple action logic from input bar to element.
* Handle with the height of input bar automatically.
* Enhance capability of input bar by adding any element you want.

## Example

<img src="https://user-images.githubusercontent.com/6101691/125613053-9c93854d-87ec-4c2e-8869-e9c383a97ace.gif" width="35%" height="35%" />

## How to use?

Create some elements then add them to input bar.

```swift

let inputBar = MessageInputBar()

// setup elements of input bar
do {
    let element = MessageInputElement(icon: .sfIconName("arrow.up.circle.fill"))
    element.enable = { $1.text.count > 0}
    element.action = { [weak self] element, inputBar in
        guard let `self` = self else {
            return
        }
        
        self.viewModel.sendMessage(text: inputBar.text)
        inputBar.resetText()
    }
    
    inputBar.add(element: element, at: .controlLocation)
}

do {
    let element = MessageInputElement(icon: .sfIconName("photo.fill"))
    element.action = { [weak self] element, inputBar in
        guard let `self` = self else {
            return
        }
        
        self.viewModel.selectPhoto()
    }

    inputBar.add(element: element, at: .functionLocation)
}

```
