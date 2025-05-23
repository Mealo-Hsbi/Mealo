// __mocks__/firebase.js
module.exports = {
  auth: () => ({
    // wir simulieren, dass jedes Token valid ist und diesen User zurückgibt
    verifyIdToken: jest.fn().mockResolvedValue({
      uid: 'test-uid-123',
      email: 'test@mealo.app',
    }),
  }),
};
