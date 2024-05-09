## Goal
### User-owned documents
 - ONLY THE USER THAT OWNS THE DOCUMENT CAN HAVE WRITE ACCESS TO IT.
### public/private users
 - The users should be able to hide their profiles
### Users COULD have a public/private user statistic
 - The users should be able to show or hide their statistics.
### Users should have public/private tests
 - The users can upload tests
 - The player should be able to hide any of their tests they choose, because, for example, the test could be incomplete.
### Tests should have a "thumbnail" and images for its questions
 - The images should ONLY BE READABLE BY A USER IF THE USER HAS ACCESS TO THE TEST.
### Tests should have user results
 - The tests should have the players' results for that test, so that other players can see how hard a test is.
 - The user results should come from the user's statistics.
### Tests should have upvotes/downvotes
 - The upvotes/downvotes of a test need to be userIds, so that a user can't upvote/downvote twice.
 - The users that upvoted/downvoted should be kept private
### Tests should have comments
 - (If the test is private, then only the test's owner could comment on it),
### Comments should have reply comments
### Comments should have upvotes/downvotes
 - Same as the ones for tests
### Comments COULD HAVE IMAGES.
 - Same as tests' images

## Schema:
```
privateUsers/
    userId: UserModel(
        ...
        userScoresId,
        publicTests,
    ),
publicUsers/
    userId: UserModel(
        ...
        userScoresId,
        publicTests,
    ),

privateUserScores/
    userId: UserScores(
        ...
        userId,
    ),
publicUserScores/
    userId: UserScores(
        ...
        userId,
    ),

privateTests/
    testId: Test(
        ...
        userId,
        userResults,
        usersThatUpvoted,
        usersThatDownvoted,
        comments,
    ),
publicTests/
    testId: Test(
        ...
        userId,
        userResults,
        usersThatUpvoted,
        usersThatDownvoted,
        comments,
    ),

privateTestUpvotes/
    upvoteId: Upvote(
        ...
        userId,
        testId,
    ),
publicTestUpvotes/
    upvoteId: Upvote(
        ...
        userId,
        testId,
    ),

privateTestDownvotes/
    upvoteId: Upvote(
        ...
        userId,
        testId,
    ),
publicTestDownvotes/
    upvoteId: Upvote(
        ...
        userId,
        testId,
    ),

privateCommentUpvotes/
    upvoteId: Upvote(
        ...
        userId,
        testId,
    ),
publicCommentUpvotes/
    upvoteId: Upvote(
        ...
        userId,
        testId,
    ),

privateCommentDownvotes/
    upvoteId: Upvote(
        ...
        userId,
        testId,
    ),
publicCommentDownvotes/
    upvoteId: Upvote(
        ...
        userId,
        testId,
    ),

comments/
    commentId: CommentTree(
        ...
        userId,
        testId,
        parentCommentId?,
        usersThatUpvoted,
        usersThatDownvoted,
        replyIds,
    ),
```
