![DogTail: Elegant Job Processing in Swift](https://raw.githubusercontent.com/bithavoc/DogTail/assets/doggy.png)

[![Build Status](https://travis-ci.org/bithavoc/DogTail.svg?branch=master)](https://travis-ci.org/bithavoc/DogTail)

> Easy and flexible job processing for OSX and iOS in Swift

**Status:** This library is a **work in progress**.

## How it Works

DogTail is a job processing framework that works as an extendable pipeline of steps allowing exceptional control over the queue.

A queue tick usually executes the pipeline in the following order:

| Step        |
| ------------- |
| Signals     |
| Conditions     |
| Consumer |
| Job <-> Task Execution |
| Analyzer |

### Signals

When emitted, signals wake up the queue and causes a tick to happen.

### Conditions

On every tick, all the conditions check to see if the pipeline can proceed to process jobs.

### Consumers
A consumer's only job is to provide the next task to be executed.

### Jobs
Every consumer uses it's own way to provide and persist jobs, inside a job there's always a `Task` to be executed. Tasks can be `synchronous`, `asynchronous` or both at the same time.

### Analyzers

If a job fails, analyzers will analyze the error(hah!) and determine what do to with it.

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate DogTail into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "bithavoc/DogTail" ~> 0.0
```

Run `carthage update` to build the framework and drag the built `DogTail.framework` into your Xcode project.

## License

DogTail is released under the MIT license. See [LICENSE](LICENSE) for details.