using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace WebGoatCore.UnitTests
{
    [TestClass]
    public class WebGoatUnitTest
    {
        [TestMethod]
        public void Test1()
        {
            int i = 5;

            Assert.AreEqual(5, i);
        }

        [TestMethod]
        public void Test2()
        {
            int i = 5;

            Assert.AreEqual(7, i + 2);
        }
        [TestMethod]
        public void Test3()
        {
            int i = 5;

            Assert.AreEqual(8, i + 3);
        }
    }
}