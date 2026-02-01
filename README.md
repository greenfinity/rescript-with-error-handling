# Rescript error wrapper for handler functions in React

A ReScript library that propagates errors from React event handlers and async operations to React error boundaries.

## The Problem

In React, errors thrown inside event handlers (like `onClick`) or async operations are not automatically caught by error boundaries. They get silently swallowed, making debugging difficult and leaving your app in an inconsistent state.

```rescript
// ❌ Errors are silently swallowed
let handleClick = () => {
  someOperationThatMightThrow() // Error lost!
}

// ❌ Async errors are also lost
let handleAsyncClick = () => {
  (async () => {
    await someAsyncOperation() // Error lost!
  })()
}
```

## The Solution

This library provides utilities to re-throw errors during React's render phase, where error boundaries can catch them.

## Installation

```bash
yarn add @greenfinity/rescript-react-with-error-handling
```

Add to your `rescript.json`:

```json
{
  "dependencies": ["@greenfinity/rescript-react-with-error-handling"]
}
```

## Usage

### Basic Setup

First, get the error handler hook in your component:

```rescript
let onError = ReactWithErrorHandling.useOnError()
```

### Synchronous Operations

Wrap synchronous operations that might throw:

```rescript
// Without return value
(() => {
  someDangerousOperation()
})->ReactWithErrorHandling.withErrorHandling(onError)

// With return value
let result = (() => {
  computeSomething()
})->ReactWithErrorHandling.withErrorHandling(onError)
```

### Async Operations

Wrap async operations with the async variant:

```rescript
// Without return value
await (async () => {
  await fetchSomeData()
})->ReactWithErrorHandling.withAsyncErrorHandling(onError)

// With return value
let data = await (async () => {
  await fetchSomeData()
})->ReactWithErrorHandling.withAsyncErrorHandling(onError)
```

## Full Example

```rescript
@react.component
let make = () => {
  let onError = ReactWithErrorHandling.useOnError()
  let (data, setData) = React.useState(() => None)

  let handleClick = _ => {
    (async () => {
      let response = await Api.fetchUserData()
      setData(_ => Some(response))
    })->ReactWithErrorHandling.withAsyncErrorHandling(onError)->ignore
  }

  <button onClick={handleClick}>
    {React.string("Load Data")}
  </button>
}
```

## API

### `useOnError`

```rescript
let useOnError: unit => (('state => 'state) => unit)
```

A React hook that returns an error dispatcher function. Call this once per component that needs error handling.

### `withErrorHandling`

```rescript
let withErrorHandling: (unit => 'return, ('state => 'state) => unit) => 'return
```

Wraps a synchronous function. If the function throws, the error is re-dispatched to trigger during React's render phase, then re-thrown.

### `withAsyncErrorHandling`

```rescript
let withAsyncErrorHandling: (unit => promise<'return>, ('state => 'state) => unit) => promise<'return>
```

Wraps an async function. If the promise rejects, the error is re-dispatched to trigger during React's render phase, then re-thrown.

## How It Works

The library uses React's `useState` hook to create a dispatcher that can trigger re-renders. When an error occurs:

1. The error is captured in the catch block
2. A state update is dispatched that will throw the error during the next render
3. The original error is also re-thrown from the handler

This ensures the error propagates to the nearest error boundary while also maintaining the original throw behavior.

## License

MIT
