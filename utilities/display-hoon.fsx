// display-hoon.fsx
open System
open System.IO

let args = Environment.GetCommandLineArgs()
let inFile = 
    File.ReadAllLines(Path.Combine([|args.[2]|]))

let outString (inString : string)  = 
  inString.Replace("8.837.943.105.650.368.721.427.405.464.935.092.336.747.891", "%selected-aggregate").
   Replace("10.144.297.770.909.009.904.293.167.460.839.466.145.177.974", "%value-literal-list").
   Replace("146.783.421.526.958.955.121.701.434.556.967.646.577", "%qualified-column").
   Replace("154.706.541.852.064.320.609.741.403.268.923.356.529", "%qualified-object").
   Replace("146.783.421.526.958.955.121.701.434.556.967.646.577", "%qualified-column").
   Replace("8.038.062.413.959.186.209.246.821.704.801", "'adoption-date'").
   Replace("8.589.255.259.980.634.887.014.616.884.321", "'adoption-email'").
   Replace("9.221.228.471.521.396.673.306.394.455.914", "%joined-object").
   Replace("5.492.821.166.363.976.505.457.336.143.683", "'COLUMN-OR-CTE'").
   Replace("31.397.524.343.186.501.141.086.955.113", "%if-then-else").
   Replace("36.020.423.716.880.455.845.514.933.617", "%query-object").
   Replace("139.547.948.725.162.322.082.688.097", "%all-columns").
   Replace("1.871.507.249.111.214.024.545", "%aggregate").
   Replace("2.129.333.263.492.008.862.817", "'adoptions'").
   Replace("7.305.809.899.972.292.451", "%coalesce").
   Replace("8.386.668.330.298.337.636", "%distinct").
   Replace("8.029.714.126.508.224.323", "CountFoo").
   Replace("32.481.125.635.289.203", "'species'").
   Replace("31.073.733.908.391.266", "%between").
   Replace("22.051.046.311.022.165", "'UNKNOWN'").
   Replace("120.325.462.585.186", "%bottom").
   Replace("125.762.588.864.358", "'foobar'").
   Replace("122.524.250.825.058", "'barfoo'").
   Replace("86.094.050.512.707", "'COLUMN'").
   Replace("500.069.396.323", "count").
   Replace("439.854.853.733", "%endif").
   Replace("362.091.466.595", "cOUNT").
   Replace("362.091.466.563", "COUNT").
   Replace("211.446.545.203", "3;2;1").
   Replace("1.701.667.182", "'name'").
   Replace("1.852.403.562", "%join").
   Replace("1.702.060.387", "%case").
   Replace("1.852.139.639", "%when").
   Replace("1.852.139.636", "%then").
   Replace("1.702.063.205", "%else").
   Replace("1.685.221.219", "cord").
   Replace("846.163.814", "'foo2'").
   Replace("846.356.834", "'bar2'").
   Replace("862.941.030", "'foo3'").
   Replace("863.134.050", "'bar3'").
   Replace("913.272.678", "'foo6'").
   Replace("879.718.246", "'foo4'").
   Replace("896.495.462", "'foo5'").
   Replace("930.049.894", "'foo7'").
   Replace("7.102.832", "%pal").
   Replace("7.368.564", "%top").
   Replace("7.105.633", "%all").
   Replace("7.496.048", "%par").
   Replace("6.581.857", "%and").
   Replace("7.958.113", "%any").
   Replace("7.303.014", "%foo").
   Replace("7.496.034", "%bar").
   Replace("7.566.700", "%lus").
   Replace("7.365.992", "%hep").
   Replace("7.496.052", "%tar").
   Replace("7.561.574", "%fas").
   Replace("7.630.702", "%not").
   Replace("7.628.139", "%ket").
   Replace("7.299.684", "'dbo'").
   Replace("6.648.940", "%lte").
   Replace("6.648.935", "%gte").
   Replace("6.581.861", "%end").
   Replace("3.236.452", "'db1'").
   Replace("29.799", "%gt").
   Replace("29.804", "%lt").
   Replace("29.537", "%as").
   Replace("29.295", "%or").
   Replace("28.265", "%in").
   Replace("29.029", "%eq").
   Replace("26.217", "%if").
   Replace("25.717", "%ud").
   Replace("25.188", "'db'").
   Replace("12.660", "'t1'").
   Replace("12.628", "'T1'").
   Replace("12.884", "'T2'").
   Replace("13.140", "'T3'").
   Replace("12.609", "'A1'").
   Replace("12.865", "'A2'")

let output =
  inFile
  |> Array.map outString

let rec loop acc n =
    if n < output.Length then
      if (n + 5) < output.Length 
        && output.[n + 1].Trim() = "0"
        && output.[n + 2].Trim() = "]"
        && output.[n + 3].Trim() = "0"
        && output.[n + 4].Trim() = "0"
        && output.[n + 5].Trim() = "]" then
          loop ((output.[n].Trim() + " 0] 0 0]").Replace("[ %", "[%").Replace("[ [", "[[")::acc) (n + 6)
      elif (n + 3) < output.Length 
        && output.[n + 1].Trim() = "0"
        && output.[n + 2].Trim() = "0"
        && output.[n + 3].Trim() = "]" then
          loop ((output.[n].Trim() + " 0 0]").Replace("[ %", "[%").Replace("[ [", "[[")::acc) (n + 4)
      elif output.[n].EndsWith("%qualified-column") then
         loop ((output.[n] + " " + output.[n + 1].Trim()).Replace("[ %", "[%").Replace("[ [", "[[")::acc) (n + 2)
      else
        loop (output.[n].Replace("[ %", "[%").Replace("[ [", "[[")::acc) (n + 1)
    else List.rev acc
  
let output2 = loop List.empty 0 

let rec loop2 (array : string []) acc n =
    if n < array.Length then
      if (n + 1) < array.Length 
        && array.[n].Trim().EndsWith("]")
        && not (array.[n + 1].Trim().StartsWith("[")) then
          loop2 array (array.[n].Trim() + " " + (array.[n + 1].Trim())::acc) (n + 2)
      else
        loop2 array (array.[n]::acc) (n + 1)
    else List.rev acc

let output3 = loop2 (List.toArray output2) List.empty 0

File.WriteAllLines(Path.Combine(args.[2] + "2"), output3)
