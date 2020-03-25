//
// Created by Kyowon Jeong on 9/25/19.
//

#include "OpenMS/ANALYSIS/TOPDOWN/MassFeatureTrace.h"

namespace OpenMS
{

  void MassFeatureTrace::findFeatures(std::vector<PeakGroup> &peakGroups,
                                      int maxSpecIndex,
                                      int &featureCntr,
                                      std::fstream &fsf,
                                      PrecalcularedAveragine &averagines,
                                      Param &mtd_param,
                                      Parameter &param)
  {

    MSExperiment map;
    boost::unordered_map<float, PeakGroup> *peakGroupMap;
    boost::unordered_map<float, int> rtSpecMap;
    std::map<int, MSSpectrum> indexSpecMap;
    peakGroupMap = new boost::unordered_map<float, PeakGroup>[maxSpecIndex + 1];

    for (auto &pg : peakGroups)
    {
      auto &spec = pg.spec;
      if (spec->getMSLevel() != 1)
      {
        continue;
      }

      if (indexSpecMap.find(pg.specIndex) == indexSpecMap.end())
      {
        indexSpecMap[pg.specIndex] = MSSpectrum();
      }
      auto &deconvSpec = indexSpecMap[pg.specIndex];
      rtSpecMap[spec->getRT()] = pg.specIndex;
      maxSpecIndex = maxSpecIndex > pg.specIndex ? maxSpecIndex : pg.specIndex;

      deconvSpec.setRT(spec->getRT());
      Peak1D tp(pg.monoisotopicMass, (float) pg.intensity);
      deconvSpec.push_back(tp);

      auto &pgMap = peakGroupMap[pg.specIndex];
      pgMap[pg.monoisotopicMass] = pg;

    }

    //int tmp = 0;
    for (auto iter = indexSpecMap.begin(); iter != indexSpecMap.end(); ++iter)
    {
      map.addSpectrum(iter->second);
    }

    std::map<int, MSSpectrum>().swap(indexSpecMap);

    if (map.size() < 3)
    {
      return;
    }
    //std::cout<<map.size()<< " " <<tmp<< std::endl;
    /*
    for (auto &pg : peakGroups)
    {
      auto &spec = pg.spec;
      if(spec->getMSLevel() != 1){
        continue;
      }
      auto &pgMap = peakGroupMap[pg.specIndex];

      pgMap[pg.monoisotopicMass] = pg;
    }*/

    for (auto it = map.begin(); it != map.end(); ++it)
    {
      it->sortByPosition();
      // cout<<it->size()<<endl;
    }

    MassTraceDetection mtdet;

    //mtd_param.setValue("mass_error_da", .3,// * (param.chargeRange+ param.minCharge),
    //                   "Allowed mass deviation (in da).");
    mtd_param.setValue("mass_error_ppm", param.tolerance[0] * 1e6, "");
    mtd_param.setValue("trace_termination_criterion", "outlier", "");

    mtd_param.setValue("reestimate_mt_sd", "false", "");
    mtd_param.setValue("quant_method", "area", "");
    mtd_param.setValue("noise_threshold_int", .0, "");

    //double rtDuration = (map[map.size() - 1].getRT() - map[0].getRT()) / ms1Cntr;
    mtd_param.setValue("min_sample_rate", 0.01, "");
    mtd_param.setValue("trace_termination_outliers", param.numOverlappedScans[0], "");
    mtd_param.setValue("min_trace_length", param.minRTSpan, "");
    //mtd_param.setValue("max_trace_length", 1000.0, "");
    mtdet.setParameters(mtd_param);

    std::vector<MassTrace> m_traces;

    mtdet.run(map, m_traces);  // m_traces : output of this function

    auto *perChargeIntensity = new double[param.chargeRange + param.minCharge + 1];
    auto *perChargeMaxIntensity = new double[param.chargeRange + param.minCharge + 1];
    auto *perChargeMz = new double[param.chargeRange + param.minCharge + 1];
    auto *perIsotopeIntensity = new double[param.maxIsotopeCount];

    for (auto &mt : m_traces)
    {
      if (mt.getSize() < 3)
      {
        //  continue;
      }
      int minCharge = param.chargeRange + param.minCharge + 1;
      int maxCharge = 0;
      boost::dynamic_bitset<> charges(param.chargeRange + param.minCharge + 1);
      std::fill_n(perChargeIntensity, param.chargeRange + param.minCharge + 1, 0);
      std::fill_n(perChargeMaxIntensity, param.chargeRange + param.minCharge + 1, 0);
      std::fill_n(perChargeMz, param.chargeRange + param.minCharge + 1, 0);
      std::fill_n(perIsotopeIntensity, param.maxIsotopeCount, 0);

      for (auto &p2 : mt)
      {
        // std::cout << p2.getRT() << " " << p2.getMZ() << std::endl;
        int specIndex = rtSpecMap[(float) p2.getRT()];
        auto &pgMap = peakGroupMap[specIndex];
        auto &pg = pgMap[(float) p2.getMZ()];
        minCharge = minCharge < pg.minCharge ? minCharge : pg.minCharge;
        maxCharge = maxCharge > pg.maxCharge ? maxCharge : pg.maxCharge;

        //std::cout<<2<<std::endl;
        for (auto &p : pg.peaks)
        {
          //std::cout<<1<<std::endl;

          if (p.isotopeIndex < 0 || p.isotopeIndex >= param.maxIsotopeCount || p.charge < 0 ||
              p.charge >= param.chargeRange + param.minCharge + 1)
          {
            continue;
          }

          charges[p.charge] = true;
          perChargeIntensity[p.charge] += p.intensity;
          perIsotopeIntensity[p.isotopeIndex] += p.intensity;
          if (perChargeMaxIntensity[p.charge] > p.intensity)
          {
            continue;
          }
          perChargeMaxIntensity[p.charge] = p.intensity;
          perChargeMz[p.charge] = p.mz;
          // std::cout<<3<<std::endl;
        }
        //std::cout<<3<<std::endl;
      }

      double chargeScore = PeakGroupScoring::getChargeFitScore(perChargeIntensity,
                                                               param.minCharge + param.chargeRange + 1);
      if (chargeScore < param.minChargeCosine) //
      {
        continue;
      }

      int offset = 0;
      double mass = mt.getCentroidMZ();
      double isoScore = PeakGroupScoring::getIsotopeCosineAndDetermineIsotopeIndex(mass,
                                                                                   perIsotopeIntensity,
                                                                                   param.maxIsotopeCount,
                                                                                   offset, averagines);
      if (isoScore < param.minIsotopeCosine[0])
      {
        continue;
      }

      //perIsotopeIntensity, param.maxIsotopeCount


      if (offset != 0)
      {
        mass += offset * Constants::ISOTOPE_MASSDIFF_55K_U;
        //avgMass += offset * Constants::C13C12_MASSDIFF_U;
        //p.isotopeIndex -= offset;
      }

      auto sumInt = .0;
      std::stringstream ss; // pgmass_strings
      std::stringstream ss_rt; // pgmass_strings
      ss.str(std::string());
      for (auto &p : mt)
      {
        sumInt += p.getIntensity();
        ss << std::to_string(p.getMZ()) << ";" ;
        ss_rt << std::to_string(p.getRT()) << ";";
      }

      auto massDelta = averagines.getAverageMassDelta(mass);

      //auto mass = mt.getCentroidMZ();
      fsf << ++featureCntr << "\t" << param.fileName << "\t" << std::to_string(mass) << "\t"
          << std::to_string(mass + massDelta) << "\t" // massdiff
          << mt.getSize() << "\t"
          //fsf << ++featureCntr << "\t" << param.fileName << "\t" << mass << "\t"
          //<< getNominalMass(mass) << "\t"
          << mt.begin()->getRT() << "\t"
          << mt.rbegin()->getRT() << "\t"
          << mt.getTraceLength() << "\t"
          << mt[mt.findMaxByIntPeak()].getRT() << "\t"
          << sumInt << "\t"
          << mt.getMaxIntensity(false) << "\t"
          << minCharge << "\t"
          << maxCharge << "\t"
          << charges.count() << "\t"
          << isoScore << "\t"
          << chargeScore << "\t"
          << ss.str() << "\t"
          << ss_rt.str() << "\n";
    }
    delete[] perIsotopeIntensity;
    delete[] perChargeMz;
    delete[] perChargeMaxIntensity;
    delete[] perChargeIntensity;
    delete[] peakGroupMap;
  }
}
