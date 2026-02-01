let useOnError = () => {
  let (_, onError) = React.useState(() => ignore())
  onError
}

let withErrorHandling: (unit => 'return, ('state => 'state) => unit) => 'return = (f, onError) => {
  try {
    f()
  } catch {
  | e =>
    onError(_ => throw(e))
    throw(e)
  }
}

let withAsyncErrorHandling: (
  unit => promise<'return>,
  ('state => 'state) => unit,
) => promise<'return> = async (f, onError) => {
  try {
    await f()
  } catch {
  | e =>
    onError(_ => throw(e))
    throw(e)
  }
}

/*

Usage:

```rescript
  let onError = useOnError()
```

Then later:

```rescript
  (() => {...})->withErrorHandling(onError)
```

or:

```rescript
  let result = (() => {...})->withErrorHandling(onError)
```

Async version:

```rescript
  await (async () => {...})->withAsyncErrorHandling(onError)
```
or:

```rescript
  let result = await (async () => {...})->withAsyncErrorHandling(onError)
```

Example pattern:

```rescript
// ❌ Wrong usage as handler- errors may be silently swallowed
let handleClick = () => {
  someAsyncOperation() // ERRORS LOST HERE
}

// ❌ Wrong async usage from handler- errors may be silently swallowed
let handleClickWithAsyncPart = () => {
  someSyncOperation()
  (async () => {...})() // ERRORS LOST HERE
  someOtherSyncOperation()
```

These are the wrong and correct ways to use withErrorHandling:

```rescript
// ❌ Wrong - errors may be silently swallowed
(() => {...})
let result = (() => {...})
```

```rescript
// ❌ Wrong async version- errors may be silently swallowed
await (async () => {...})()
let result = await (async () => {...})()
```

```rescript
// ✅ Correct - errors propagate to error boundary
let onError = useOnError()
```

```rescript
(() => {...})->withErrorHandling(onError)
let result = (() => {...})->withErrorHandling(onError)
```

```rescript
// ✅ Correct async version - errors propagate to error boundary
let onError = useOnError()
```

```rescript
await (async () => {...})->withAsyncErrorHandling(onError)
let result = await (async () => {...})->withAsyncErrorHandling(onError)
```

 */
