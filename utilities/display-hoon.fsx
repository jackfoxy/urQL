// display-hoon.fsx
open System
open System.IO

let args = Environment.GetCommandLineArgs()
let inFile = 
    File.ReadAllLines(Path.Combine([|args.[2]|]))

let outString (inString : string)  = 
  inString.Replace("649.248.771.441.893.411.817.982.870.561.182.956.542.737.351.252.646.344.025.446", "%federal-holidays-floating").
   Replace("185.434.398.490.075.006.205.942.160.925.085.077.746.044.852.363.313.602.130.964.595", "%species-vital-signs-ranges").
   Replace("11.625.936.288.482.434.894.277.242.286.701.083.339.040.499.965.367.181.667", "%calendar-us-fed-holiday").
   Replace("37.562.741.010.413.199.970.225.013.435.829.723.509.090.067.614.557.542", "%federal-holidays-fixed").
   Replace("152.586.546.985.179.904.404.566.662.046.940.907.022.723.518.260.594", "%respiratory-rate-high").
   Replace("681.854.708.019.517.254.551.005.547.297.474.567.534.713.988.466", "%respiratory-rate-low").
   Replace("2.573.421.258.995.314.004.335.748.811.314.105.646.492.512.099", "%common-street-names").
   Replace("2.573.421.258.995.313.369.282.137.451.195.094.694.892.498.787", "%common-animal-names").
   Replace("2.573.421.258.995.313.532.078.548.508.498.801.693.165.449.059", "%common-person-names").
   Replace("10.573.727.457.524.396.317.529.590.760.370.274.143.400.821", "%us-federal-holiday").
   Replace("10.144.297.770.909.009.904.293.167.460.839.466.145.177.974", "%value-literal-list").
   Replace("8.837.943.105.650.368.721.427.405.464.935.092.336.747.891", "%selected-aggregate").
   Replace("39.287.235.853.266.820.421.875.523.955.069.745.722.483", "%staff-assignments").
   Replace("39.267.323.312.809.183.528.503.897.748.730.985.806.195", "'sys.sys.databases'").
   Replace("170.141.184.492.629.764.369.765.697.822.549.606.400", "~2000.1.10").
   Replace("170.141.184.492.628.170.571.077.729.317.289.984.000", "~2000.1.9").
   Replace("170.141.184.492.626.576.772.389.760.812.030.361.600", "~2000.1.8").
   Replace("170.141.184.492.624.982.973.701.792.306.770.739.200", "~2000.1.7").
   Replace("170.141.184.492.623.389.175.013.823.801.511.116.800", "~2000.1.6").
   Replace("170.141.184.492.621.795.376.325.855.296.251.494.400", "~2000.1.5").
   Replace("170.141.184.492.620.201.577.637.886.790.991.872.000", "~2000.1.4").
   Replace("170.141.184.492.618.607.778.949.918.285.732.249.600", "~2000.1.3").
   Replace("170.141.184.492.617.013.980.261.949.780.472.627.200", "~2000.1.2").
   Replace("170.141.184.492.615.420.181.573.981.275.213.004.800", "~2000.1.1").
   Replace("154.706.541.852.064.320.609.741.403.268.923.356.529", "%qualified-object").
   Replace("153.387.880.912.749.968.533.916.195.583.951.204.467", "%species-vaccines").
   Replace("146.783.421.526.958.955.121.701.434.556.967.646.577", "%qualified-column").
   Replace("138.776.656.044.847.090.402.796.018.744.997.799.284", "%temperature-high").
   Replace("134.820.126.789.392.367.864.943.981.452.696.183.158", "%vaccination-time").
   Replace("620.143.244.322.668.829.936.466.474.793.002.356", "%temperature-low").
   Replace("573.372.740.339.683.418.662.852.337.114.313.327", "%ordering-column").
   Replace("542.096.312.675.183.982.337.638.099.132.179.816", "%heart-rate-high").
   Replace("521.362.938.918.930.596.810.185.498.367.651.177", "%implant-chip-id").
   Replace("2.422.434.548.135.460.568.655.473.076.692.328", "%heart-rate-low").
   Replace("2.360.793.573.671.302.145.010.020.337.413.749", "%unmatch-target").
   Replace("2.340.510.231.993.983.394.008.745.045.682.531", "%city-zip-codes").
   Replace("2.320.232.770.534.244.696.397.211.505.356.385", "%animal-shelter").
   Replace("2.057.743.977.973.551.669.566.099.629.630.561", "%admission-date").
   Replace("9.221.228.471.521.396.673.306.394.455.914", "%joined-object").
   Replace("9.066.494.452.717.006.206.037.855.400.560", "%primary-color").
   Replace("8.589.255.259.980.634.887.014.616.884.321", "%adoption-email").
   Replace("8.038.062.413.959.186.209.246.821.704.801", "%adoption-date").
   Replace("7.954.196.879.087.005.735.725.065.399.905", "%animals-breed").
   Replace("5.492.821.166.363.976.505.457.336.143.683", "'COLUMN-OR-CTE'").
   Replace("32.327.197.932.263.948.726.153.339.236", "%day-of-month").
   Replace("31.397.524.343.186.501.141.086.955.113", "%if-then-else").
   Replace("31.380.570.019.179.360.524.000.257.121", "%adoption-fee").
   Replace("36.020.423.716.880.455.845.514.933.617", "%query-object").
   Replace("35.724.284.097.586.123.762.747.793.782", "%vaccinations").
   Replace("139.547.948.725.162.322.082.688.097", "%all-columns").
   Replace("139.505.428.549.343.153.271.960.691", "%staff-roles").
   Replace("138.277.484.837.805.406.398.538.084", "%day-of-year").
   Replace("129.833.893.422.319.292.680.593.764", "%day-of-week").
   Replace("121.413.839.493.834.722.620.239.461", "%end-command").
   Replace("549.830.960.776.754.863.825.252", "%data-agent").
   Replace("549.665.932.582.020.998.980.978", "%result-set").
   Replace("521.515.500.513.432.469.270.384", "%population").
   Replace("479.105.854.866.430.478.149.986", "%birth-date").
   Replace("478.976.730.472.715.801.225.574", "%first-name").
   Replace("478.976.730.472.664.278.134.637", "%month-name").
   Replace("478.811.715.486.079.793.591.411", "%state-code").
   Replace("246.400.468.917.004.496.894.317", "%my-table-4").
   Replace("241.678.102.434.134.851.680.621", "%my-table-3").
   Replace("236.955.735.951.265.206.466.925", "%my-table-2").
   Replace("2.203.193.075.856.625.202.545", "%query-row").
   Replace("2.147.777.190.534.199.867.763", "%sys-agent").
   Replace("2.129.333.263.492.008.862.817", "%adoptions").
   Replace("2.074.352.768.080.550.322.532", "%data-tmsp").
   Replace("2.073.630.783.665.775.862.116", "%data-ship").
   Replace("1.981.107.992.894.476.739.961", "%year-week").
   Replace("1.871.507.249.111.214.024.545", "%aggregate").
   Replace("1.871.507.245.571.943.590.248", "%hire-date").
   Replace("1.871.507.244.730.112.373.360", "'predicate'").
   Replace("1.871.002.853.409.046.094.188", "%last-name").
   Replace("1.870.285.927.043.859.637.618", "%reference").
   Replace("1.870.282.279.968.085.729.646", "%namespace").
   Replace("8.746.603.395.657.527.919", "%order-by").
   Replace("8.746.603.387.336.749.671", "%group-by").
   Replace("8.674.334.399.035.367.780", "%date-max").
   Replace("8.386.668.330.298.337.636", "%distinct").
   Replace("8.319.395.793.566.789.475", "%comments").
   Replace("8.317.711.341.870.932.336", "%patterns").
   Replace("8.315.173.685.927.567.734", "%vaccines").
   Replace("8.241.979.218.375.500.131", "%calendar").
   Replace("8.102.940.500.315.830.643", "%sys-tmsp").
   Replace("8.029.714.126.508.224.323", "CountFoo").
   Replace("7.956.010.258.469.773.668", "%date-min").
   Replace("7.310.293.695.322.153.316", "%database").
   Replace("7.308.604.896.129.409.380", "%day-name").
   Replace("7.308.324.466.015.959.405", "%my-table").
   Replace("7.306.086.967.256.574.330", "%zip-code").
   Replace("7.305.809.899.972.292.451", "%coalesce").
   Replace("7.234.309.766.870.430.561", "%assigned").
   Replace("34.165.556.108.420.471", "%weekday").
   Replace("34.165.556.075.327.336", "%holiday").
   Replace("32.497.631.497.512.306", "%results").
   Replace("32.496.501.869.798.497", "%address").
   Replace("32.491.047.279.027.568", "%persons").
   Replace("32.488.788.024.979.041", "%animals").
   Replace("32.481.125.635.289.203", "%species").
   Replace("31.088.027.509.219.696", "%pattern").
   Replace("31.073.733.908.391.266", "%between").
   Replace("28.550.371.565.855.094", "%vaccine").
   Replace("28.549.237.880.026.483", "%surname").
   Replace("28.258.996.690.641.261", "%matched").
   Replace("22.051.046.311.022.165", "'UNKNOWN'").
   Replace("133.540.976.357.219", "%county").
   Replace("128.034.677.157.481", "%insert").
   Replace("127.978.842.518.643", "%street").
   Replace("127.970.252.186.995", "%select").
   Replace("126.935.332.843.363", "%colors").
   Replace("126.879.598.928.246", "'values'").
   Replace("126.879.581.434.995", "%states").
   Replace("126.879.398.127.971", "%cities").
   Replace("126.875.035.071.074", "%breeds").
   Replace("125.779.802.219.879", "%gender").
   Replace("125.762.588.864.358", "'foobar'").
   Replace("122.524.250.825.058", "'barfoo'").
   Replace("120.325.462.585.186", "%bottom").
   Replace("111.550.524.584.053", "%update").
   Replace("111.516.165.432.678", "%female").
   Replace("86.094.050.512.707", "'COLUMN'").
   Replace("500.069.396.323", "'count'").
   Replace("500.068.345.697", "'agent'").
   Replace("491.495.649.123", "%color").
   Replace("478.560.413.032", "'hello'").
   Replace("465.624.460.645", "%email").
   Replace("448.629.993.325", "%month").
   Replace("448.345.170.274", "%batch").
   Replace("444.234.036.085", "%using").
   Replace("439.854.853.733", "%endif").
   Replace("439.804.327.027", "%staff").
   Replace("435.744.240.755", "%state").
   Replace("435.710.945.399", "%where").
   Replace("435.610.083.700", "'table'").
   Replace("431.197.876.834", "%breed").
   Replace("362.091.466.595", "'cOUNT'").
   Replace("362.091.466.563", "'COUNT'").
   Replace("211.446.545.203", "3;2;1").
   Replace("2.037.672.291", "%city").
   Replace("1.936.028.771", "%ctes").
   Replace("1.918.985.593", "%year").
   Replace("1.869.901.417", "%into").
   Replace("1.852.403.562", "%join").
   Replace("1.836.020.326", "%from").
   Replace("1.852.139.639", "%when").
   Replace("1.852.139.636", "%then").
   Replace("1.802.396.018", "%rank").
   Replace("1.702.125.924", "%date").
   Replace("1.702.063.205", "%else").
   Replace("1.702.060.387", "%case").
   Replace("1.701.667.182", "%name").
   Replace("1.701.605.234", "%role").
   Replace("1.701.601.645", "%male").
   Replace("1.685.221.219", "'cord'").
   Replace("930.049.894", "'foo7'").
   Replace("913.272.678", "'foo6'").
   Replace("896.495.462", "'foo5'").
   Replace("896.298.851", "'col5'").
   Replace("879.718.246", "'foo4'").
   Replace("879.521.635", "'col4'").
   Replace("863.134.050", "'bar3'").
   Replace("862.941.030", "'foo3'").
   Replace("862.744.419", "%col3").
   Replace("846.356.834", "'bar2'").
   Replace("846.163.814", "'foo2'").
   Replace("845.967.203", "%col2").
   Replace("829.189.987", "%col1").
   Replace("7.958.113", "%any").
   Replace("7.954.788", "%day").
   Replace("7.566.700", "%lus").
   Replace("7.561.574", "%fas").
   Replace("7.630.702", "%not").
   Replace("7.628.660", "'tgt'").
   Replace("7.628.147", "%set").
   Replace("7.628.139", "%ket").
   Replace("7.567.731", "%sys").
   Replace("7.561.588", "%tas").
   Replace("7.496.052", "%tar").
   Replace("7.496.048", "%par").
   Replace("7.496.034", "%bar").
   Replace("7.368.564", "%top").
   Replace("7.365.992", "%hep").
   Replace("7.303.014", "%foo").
   Replace("7.299.684", "%dbo").
   Replace("7.107.189", "%url").
   Replace("7.106.403", "'col'").
   Replace("7.105.633", "%all").
   Replace("7.102.832", "%pal").
   Replace("6.581.861", "%end").
   Replace("6.581.857", "%and").
   Replace("6.517.363", "'src'").
   Replace("6.710.642", "%ref").
   Replace("6.648.940", "%lte").
   Replace("6.648.935", "%gte").
   Replace("6.648.931", "%cte").
   Replace("3.301.988", "%db2").
   Replace("3.236.452", "%db1").
   Replace("29.799", "%gt").
   Replace("29.804", "%lt").
   Replace("29.554", "%rs").
   Replace("29.550", "%ns").
   Replace("29.537", "%as").
   Replace("29.295", "%or").
   Replace("28.265", "%in").
   Replace("29.029", "%eq").
   Replace("28.271", "%on").
   Replace("26.217", "%if").
   Replace("25.717", "%ud").
   Replace("25.188", "'db'").
   Replace("24.932", "%da").
   Replace("13.140", "'T3'").
   Replace("12.916", "'t2'").
   Replace("12.884", "'T2'").
   Replace("12.865", "'A2'").
   Replace("12.660", "'t1'").
   Replace("12.628", "'T1'").
   Replace("12.609", "'A1'").
   Replace("116", "%t").
   Replace("112", "%p")

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
