Add-Type @"
namespace test0001
{
    public class NonGenericClass
    {
        public string Method5(string value)
        {
            return value;
        }
        public static string Method6(string value)
        {
            return value;
        }
        public T Method1<T>(string value)
            where T : new()
        {
            return new T();
        }
        public string Method2<T>(T value)
        {
            return value.ToString();
        }
        public static T Method3<T>(string value)
            where T : new()
        {
            return new T();
        }
        public static string Method4<T>(T value)
        {
            return value.ToString();
        }

        public T OverloadMethod1<T>(string value)
            where T : new()
        {
            return new T();
        }
        public T OverloadMethod1<T>(int value)
            where T : new()
        {
            return new T();
        }

        public string OverloadMethod2<T>(T value)
        {
            return value.ToString();
        }
        public T OverloadMethod2<T>(string value)
            where T : new()
        {
            return new T();
        }
		
        public static T OverloadMethod3<T>(string value)
            where T : new()
        {
            return new T();
        }
        public static T OverloadMethod3<T>(int value)
            where T : new()
        {
            return new T();
        }

        public static string OverloadMethod4<T>(T value)
        {
            return value.ToString();
        }
        public static T OverloadMethod4<T>(string value)
            where T : new()
        {
            return new T();
        }
    }
}
"@;
[Type[]] $types = @([string])
$mi = [test0001.NonGenericClass].GetMethod("OverloadMethod4", $types);
$gmi = $mi.MakeGenericMethod([System.DateTimeOffset]);
$gmi.Invoke([test0001.NonGenericClass], "tralala")


[biz.dfch.CS.Appclusive.Public.Converters.EntityBagConverter]::Convert
[Type[]] $types = @([biz.dfch.CS.Appclusive.Public.DictionaryParameters])
$mi = [biz.dfch.CS.Appclusive.Public.Converters.EntityBagConverter].GetMethod("Convert", $types);
$gmi = $mi.MakeGenericMethod([biz.dfch.Appclusive.Products.Infrastructure.V001.Disk]);
$gmi.Invoke([biz.dfch.CS.Appclusive.Public.Converters.EntityBagConverter], $dic)
